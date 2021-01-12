class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true
  mount_uploader :file, ImageAttachmentUploader
  store_in_background :file
  VALID_EXTENTIONS = ['pdf','jpg', 'jpeg', 'png', 'gif' ]
  after_create :process_upload

  def process_upload
    self.remote_file_url = self.s3_file_url
    self.save
  end
  
  def processing?
    file_tmp.present? || file_processing?
  end

  def small_url
    (file.blank?) ? (s3_file_url || "ediofy/ediofy-placeholder.png") : (version_exists(file_url(:small)) ? file_url(:small) : (s3_file_url || "ediofy/ediofy-placeholder.png"))
  end

  def medium_url
    (file.blank?) ? (s3_file_url || "ediofy/ediofy-placeholder.png") : (version_exists(file_url(:medium)) ? file_url(:medium) : (s3_file_url || "ediofy/ediofy-placeholder.png"))
  end

  def large_url
    (file.blank?) ? (s3_file_url || "ediofy/ediofy-placeholder.png") : (version_exists(file_url(:large)) ? file_url(:large) : (s3_file_url || "ediofy/ediofy-placeholder.png"))
  end

  def version_exists(url)
    uri = URI(url)

    request = Net::HTTP.new uri.host
    response= request.request_head uri.path
    return response.code.to_i == 200
  end

end
