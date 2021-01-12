class TaggerInput < Formtastic::Inputs::StringInput
  def input_html_options
  	if object.blank?
  		super.merge( { :class => "tagger" } )
  	else
	    tags = []
      object.tag_list.each do |t|
       tag = Tag.find_by_name(t)
       tags << {id: tag.blank? ? nil : tag.id, label: t, name: t}
      end
      super.merge( { :class => "tagger", :'data-tagger-initial' => tags.to_json } )
	  end
  end
end