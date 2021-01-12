module Ediofy::OpengraphHelper
  def meta_tags_for(object)
    output = ''
    case object.class.to_s
    when 'Media'
      output += tag :meta, name: "twitter:card", content: "summary"
      output += tag :meta, name: "twitter:site:id", content: "990372380"

      output += tag :meta, name: "twitter:creator:id", content: object.user.twitter_uid if object.user.twitter?
      output += tag :meta, property: "og:url", content: ediofy_media_url(@media)
      output += tag :meta, property: "og:title", content: truncate_html(object.title, 70)
      output += tag :meta, property: "og:description", content: truncate_html(object.description, 200)
      output += tag :meta, property: "og:image", content: object.file.thumb.url
      output += tag :meta, property: "og:image:width", content: Media::IMAGE_SIZES[:thumb][0]
      output += tag :meta, property: "og:image:height", content: Media::IMAGE_SIZES[:thumb][1]

    end
    output.html_safe
  end

end