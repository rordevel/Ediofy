class Ediofy::LinksController < EdiofyController
  before_action :set_content, only: %i[sort]
  before_action :check_authorization, only: %i[sort]

  def resort
    params[:content].each_with_index do |id, index|
       Content.where(id: id).update_all(position: index + 1)
    end
    respond_to do |format|
        format.js
    end
  end

  private

  def content_params
    params.require(:link).permit(:title,:url, :description, :page_image, :private, :page_description,
                                 :tag_list, :posted_as_group, :group_id, :posted_as_group,
                                 images_attributes: [:file, :s3_file_name, :s3_file_url, :position, :id, :_destroy])
  end

end
