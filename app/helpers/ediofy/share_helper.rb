module Ediofy::ShareHelper

  def facebook_share(url, text='', link='Share on facebook')
    app_id = Devise::omniauth_configs[:facebook].args[0]
    if app_id
      absolute_url = Rails.application.routes.url_helpers.ediofy_root_url(host: ENV['DOMAIN_NAME'])
      absolute_url += url
      #url = polymorphic_path(url, { only_path: false }) unless url.is_a? String
      ## Google Analytics variables
      #url = "#{url}?utm_source=gmep&utm_campaign=share&utm_medium=facebook&utm_content=#{url}"
      url = CGI.escape(absolute_url)
      link_to content_tag(:i, '', class: 'fa fa-facebook-square'), "https://www.facebook.com/dialog/feed?display=popup&app_id=#{app_id}&link=#{url}&redirect_uri=#{url}", :target => "_blank", :class => "facebook", :title => link
    end
  end

  def twitter_share(url, text='', link='Share on twitter')
    absolute_url = Rails.application.routes.url_helpers.ediofy_root_url(host: ENV['DOMAIN_NAME'])
    absolute_url += url
    ## Google Analytics variables
    #url = "#{url}?utm_source=gmep&utm_campaign=share&utm_medium=facebook&utm_content=#{url}"
    text = "#{text}"
    url = CGI.escape(absolute_url)
    link_to content_tag(:i, '', class: 'fa fa-twitter-square'), "https://twitter.com/share?text=#{CGI.escape(text)}+%23EDIOFY&url=#{url}", :target => "_blank", :class => "twitter", :title => link
  end

  def linkedin_share(url, text='', link='Share on linkedin')
    absolute_url = Rails.application.routes.url_helpers.ediofy_root_url(host: ENV['DOMAIN_NAME'])
    absolute_url += url
    # url = polymorphic_path(url, { only_path: false }) unless url.is_a? String
    ## Google Analytics variables
    #url = "#{url}?utm_source=gmep&utm_campaign=share&utm_medium=facebook&utm_content=#{url}"
    text = "#{text}"
    url = CGI.escape(absolute_url)
    link_to content_tag(:i, '', class: 'fa fa-linkedin-square'), "http://www.linkedin.com/shareArticle?mini=true&url=#{url}&title=#{CGI.escape(text)}+%23EDIOFY&summary=#{CGI.escape(text)}", :target => "_blank", :class => "linkedin", :title => link
  end

end