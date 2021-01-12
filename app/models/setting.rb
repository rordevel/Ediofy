class Setting < ActiveRecord::Base
  belongs_to :user

  serialize :tag_choice

  validates_presence_of :user

  ANSWERS_RESET = {
    monthly: 'Monthly',
    exhausted: 'When Exhausted'
  }

  PRIVACY_OPEN=1
  PRIVACY_MEDIUM=2
  PRIVACY_STEALTH=3

  def tag_choice
    @tags ||= Tag.all.collect { |t| t.id.to_s }
    super || @tags
  end

  def tag_ids=(attr)
    self.tag_choice = attr
  end

  def tag_ids
    self.tag_choice
  end

  def tags
    tags = Tag.select(:id, :title).where(id: self.tag_ids)
  end
end