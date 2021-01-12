class Interest < Tag
	default_scope -> { where(tag_type: Tag.tag_types[:Interest]) }
  def display_name
    name
  end
end