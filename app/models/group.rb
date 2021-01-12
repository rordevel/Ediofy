class Group < ActiveRecord::Base
  MEMBER_ROLES = %i[owner admin user]

  # all group members
  has_many :group_members, class_name: 'GroupMembership', dependent: :destroy
  has_many :members, through: :group_members, foreign_key: :member_id

  # only group owners
  has_many :group_owners, ->{ where(member_type: :owner) }, class_name: 'GroupMembership'
  has_many :owners, through: :group_owners, foreign_key: :member_id

  # only group admins
  has_many :group_admins, ->{ where(member_type: :admin) }, class_name: 'GroupMembership'
  has_many :admins, through: :group_admins, foreign_key: :member_id

  # only group users
  has_many :group_users, ->{ where(member_type: :user) }, class_name: 'GroupMembership'
  has_many :users, through: :group_users, foreign_key: :member_id

  has_and_belongs_to_many :links, after_add: [:notify, :update_textsearch_cache], after_remove: :update_textsearch_cache, dependent: :destroy
  has_and_belongs_to_many :media, after_add: [:notify, :update_textsearch_cache], after_remove: :update_textsearch_cache, dependent: :destroy
  has_and_belongs_to_many :questions, after_add: [:notify, :update_textsearch_cache], after_remove: :update_textsearch_cache, dependent: :destroy
  has_and_belongs_to_many :conversations, after_add: [:notify, :update_textsearch_cache], after_remove: :update_textsearch_cache, dependent: :destroy

  has_many :group_invites, dependent: :destroy
  has_many :unaccepted_group_invites, ->{ where(accepted: nil)}, class_name: 'GroupInvite'

  alias :invites :group_invites
  alias :unaccepted_invites :unaccepted_group_invites

  has_many :announcements, dependent: :destroy
  has_many :playlists, dependent: :destroy

  accepts_nested_attributes_for :users, :admins, :owners, :members

  mount_uploader :image, AvatarUploader

  after_save :update_textsearch_cache
  after_touch :update_textsearch_cache

  def self.taggings_query
    <<-SQL
      SELECT
        g.id,
        'groups' AS type,
        TO_TSVECTOR(g.textsearch_cache) AS textsearch,
        g.created_at
      FROM groups g
      GROUP BY g.id
    SQL
  end

  def owner?(user)
    owners.include? user
  end

  def admin?(user)
    admins.include? user
  end

  def hideArchivedPlaylists 
    playlists.where.not(archived: false)
  end

  def regular_user?(user)
    users.include? user
  end

  def able_edit?(user)
    owner?(user) || admin?(user)
  end

  def user_role(user)
    group_members.find do |membership|
      membership.group == self && membership.user == user
    end&.member_type
  end

  def in_group?(user)
    members.include? user
  end

  def content
    links + media + questions + conversations
  end


  def query_content(query)
    title_results =    content.select { |c| c.title.downcase.include?(query.downcase) }
    tag_results =  content_tagged_with_query(query)
    
    title_results + tag_results

  end

  def top_content_in_search(query)
    title_results =    content.select { |c| c.title.downcase.include?(query.downcase) }
    tag_results =  content_tagged_with_query(query)

    title_results + tag_results
    (title_results + tag_results).sort_by(&:votes_count)
      #//links.order('comments_count DESC').limit(5) + media.order('comments_count DESC').limit(5) + questions.order('comments_count DESC').limit(5) + conversations.order('comments_count DESC').limit(5)
  end

  def top_content
    links.order('comments_count DESC').limit(5) + media.order('comments_count DESC').limit(5) + questions.order('comments_count DESC').limit(5) + conversations.order('comments_count DESC').limit(5)
end



  def user_invite(user)
    group_invites.find do |invite|
      invite.group == self && invite.user == user && invite.accepted == nil
    end
  end

  def invited?(user)
    user_invite(user).present?
  end

  def to_s
    title
  end

  private

    def content_tagged_with_query(query)
      links.tagged_with(query) + media.tagged_with(query) + questions.tagged_with(query) + conversations.tagged_with(query)
    end

    def update_textsearch_cache(content = nil)
      query = content_textsearch_query(id)
      result = ActiveRecord::Base.connection.execute(query)
      self.update_column(:textsearch_cache, result.first['textsearch'])
    end

    def content_textsearch_query(group_id)
      <<-SQL
        SELECT CONCAT(
          COALESCE(g.title, ' '),
          ' ',
          COALESCE(c.textsearch, ' '),
          ' ',
          COALESCE(l.textsearch, ' '),
          ' ',
          COALESCE(m.textsearch, ' '),
          ' ',
          COALESCE(q.textsearch, ' ')
        ) AS textsearch
        FROM groups g
        LEFT JOIN (
          SELECT
          cg.group_id,
          CONCAT(COALESCE(STRING_AGG(t.name, ' '), ''), ' ', COALESCE(STRING_AGG(c.title, ' '), '')) AS textsearch
          FROM conversations c
          LEFT JOIN conversations_groups cg ON cg.conversation_id = c.id
          LEFT JOIN taggings tg ON tg.taggable_type = 'Conversation' AND tg.taggable_id = c.id
          LEFT JOIN tags t ON t.id = tg.tag_id
          WHERE cg.group_id = #{group_id}
          GROUP BY cg.group_id
        ) c ON c.group_id = g.id
        LEFT JOIN (
          SELECT
          gl.group_id,
          CONCAT(COALESCE(STRING_AGG(t.name, ' '), ''), ' ', COALESCE(STRING_AGG(l.title, ' '), '')) AS textsearch
          FROM links l
          LEFT JOIN groups_links gl ON gl.link_id = l.id
          LEFT JOIN taggings tg ON tg.taggable_type = 'Link' AND tg.taggable_id = l.id
          LEFT JOIN tags t ON t.id = tg.tag_id
          WHERE gl.group_id = #{group_id}
          GROUP BY gl.group_id
        ) l ON l.group_id = g.id
        LEFT JOIN (
          SELECT
          gm.group_id,
          CONCAT(COALESCE(STRING_AGG(t.name, ' '), ''), ' ', COALESCE(STRING_AGG(m.title, ' '), '')) AS textsearch
          FROM media m
          LEFT JOIN groups_media gm ON gm.media_id = m.id
          LEFT JOIN taggings tg ON tg.taggable_type = 'Media' AND tg.taggable_id = m.id
          LEFT JOIN tags t ON t.id = tg.tag_id
          WHERE gm.group_id = #{group_id}
          GROUP BY gm.group_id
        ) m ON m.group_id = g.id
        LEFT JOIN (
          SELECT
          gq.group_id,
          CONCAT(COALESCE(STRING_AGG(t.name, ' '), ''), ' ', COALESCE(STRING_AGG(q.title, ' '), '')) AS textsearch
          FROM questions q
          LEFT JOIN groups_questions gq ON gq.question_id = q.id
          LEFT JOIN taggings tg ON tg.taggable_type = 'Question' AND tg.taggable_id = q.id
          LEFT JOIN tags t ON t.id = tg.tag_id
          WHERE gq.group_id = #{group_id}
          GROUP BY gq.group_id
        ) q ON q.group_id = g.id
        WHERE g.id = #{group_id}
      SQL
    end

    def notify(content)
      members.reject { |member| member == content.user }.each do |member|
        member.notifications.create title: "New #{content.class} added to group #{self.title}"
      end
    end
end
