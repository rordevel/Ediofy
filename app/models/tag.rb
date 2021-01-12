class Tag < ActiveRecord::Base
	enum tag_type: [:Tag, :Interest]

	mount_uploader :image, TagUploader
  validates :image, presence: true, if: lambda { |t| t.Interest?  }
  validates :name, presence: true
  has_ancestry
end