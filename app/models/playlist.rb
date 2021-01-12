# frozen_string_literal:true

class Playlist < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  has_many :playlist_contents
  has_many :conversations, through: :playlist_contents, source: :playable, source_type: Conversation.class_name
  has_many :links, through: :playlist_contents, source: :playable, source_type: Link.class_name
  has_many :media, through: :playlist_contents, source: :playable, source_type: Media.class_name
  has_many :questions, through: :playlist_contents, source: :playable, source_type: Question.class_name

  def content
    playlist_contents.includes(:playable)
  end

  def media_count
    media.count
  end

  def link_count
    links.count
  end

  def question_count
    questions.count
  end

  def conversation_count
    conversations.count
  end

  def video_count
    media.count
  end
end
