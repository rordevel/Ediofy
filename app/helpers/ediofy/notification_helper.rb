module Ediofy::NotificationHelper

  def notification_url_helper(link)

    link_url = ''
    begin
      link_url = url_for(link[:href])
    rescue NoMethodError
    end

    if link_url.present?
      link_to link[:title].html_safe, link_url, method: link[:method] || :get
    else
      ""
    end
  end

end