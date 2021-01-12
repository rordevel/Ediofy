module OembedProvidable #:nodoc:
  extend ActiveSupport::Concern

  included do
    [:type, :url, :width, :height, :author_name, :author_url, :thumbnail_url, :thumbnail_height, :thumbnail_width].each do |k|
      attr_accessor "oembed_#{k}"
    end
  end

  def oembed_max_dimensions(max_width=nil, max_height=nil)
    if max_width.present? and max_height.present?
      ((oembed_width > max_width.to_i) && (oembed_height > max_height.to_i)) ? [max_width, max_height] : [oembed_width, oembed_height]
    else
      [oembed_width, oembed_height]
    end
  end

  def oembedable
    true
  end

  def oembed_html=(html)
    @embed_html = html
  end

  def oembed_html
    @embed_html || '<iframe src="%URL%" width="'+oembed_width.to_s+'" height="'+oembed_height.to_s+'" frameborder="0" scrolling="no"></iframe>'
  end

  def oembed_title
    to_s
  end

  def oembed_provider_name
    OembedProvider.provider_name
  end

  def oembed_provider_url
    OembedProvider.provider_url
  end

  def oembed_cache_age
    OembedProvider.cache_age
  end

  def oembed_version
    OembedProvider.version
  end

  def oembed_as_json(options={})
    json={}
    attributes = OembedProvider.required_attributes[oembed_type] + OembedProvider.optional_attributes + OembedProvider.base_attributes
    attributes.each do |attr|
      next if attr.to_s.include?('max')
      value = self.send("oembed_#{attr}")
      json[attr]=value if value.present?
    end
    json[:type] = oembed_type
    json.to_json
  end

  def oembed_to_xml(options = {})
    attributes = OembedProvider.required_attributes[oembed_type] + OembedProvider.optional_attributes + OembedProvider.base_attributes

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.oembed {
        attributes.each do |attr|
          next if attr.to_s.include?('max')
          value = self.send("oembed_#{attr}")
          xml.send(attr, value) if value.present?
        end
      }
    end

    builder.to_xml
  end

end