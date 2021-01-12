module Ediofy::MediaHelper

  def form_file_hint_helper(object)
    unless object.url.nil?
      link_to object.url, title: 'Right click to Save-as' do
        image_tag(object.thumb.url)+tag("br")+"Click here to save original"
      end
    end
  end

  def media_type_overlay(media)
    if media.media_type.present?
      content_tag :span, media.media_type, class: ['media-type', media.media_type]
    end
  end

  def atom_media_mime_type(path,type)
    types = MIME::Types.of(path)
    types.reject { |t| t.to_s[0..4] != type }.first
  end

end