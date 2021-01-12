class AddCachedVotesToVotables < ActiveRecord::Migration[5.1]
  def change
    klasses = %w(Announcement Comment Conversation EdiofyUserExam Link Question)

    klasses.each do |klass|
      model = klass.constantize

      change_table model.table_name do |t|
        t.integer :cached_votes_up, default: 0
        t.integer :cached_votes_down, default: 0
      end

      model.find_each(&:update_cached_votes)
    end
  end
end
