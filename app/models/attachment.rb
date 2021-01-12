class Attachment < ApplicationRecord
  belongs_to :media_file
  belongs_to :attachable, polymorphic: true
end
