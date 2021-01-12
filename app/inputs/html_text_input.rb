class HtmlTextInput < Formtastic::Inputs::TextInput
  def to_html
    input_wrapping do
      label_html <<
      template.content_tag(:div, id: "#{dom_id}_html_input", class: "html-input") do
        template.content_tag(:div, id: "#{dom_id}_toolbar", class: "html-input-toolbar", style: "display:none" ) do
          template.content_tag(:a, "Bold", "data-wysihtml5-command" => "bold") <<
          template.content_tag(:a, "Italic", "data-wysihtml5-command" => "italic") <<
          template.content_tag(:a, "Unordered List", "data-wysihtml5-command" => "insertUnorderedList") <<
          template.content_tag(:a, "Ordered List", "data-wysihtml5-command" => "insertOrderedList") <<
          template.content_tag(:a, "Link", "data-wysihtml5-command" => "createLink") <<

          template.content_tag(:div, "data-wysihtml5-dialog" => "createLink", class: "wysihtml5-dialog", style: "display:none") do
            template.content_tag(:label, "Link:") <<
            template.tag(:input, "data-wysihtml5-dialog-field" => "href", value: "http://") <<
            template.content_tag(:a, "Save", "data-wysihtml5-dialog-action" => "save") <<
            template.content_tag(:a, "Cancel", "data-wysihtml5-dialog-action" => "cancel")
          end

        end <<
        builder.text_area(method, input_html_options)
      end
    end
  end
end