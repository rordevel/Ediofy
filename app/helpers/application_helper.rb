module ApplicationHelper
  def active_tab
    return "conversation" if params[:controller] == "ediofy/conversations"
    return "share" if ["ediofy/uploads"].include?(params[:controller]) || ["ediofy/media/new", "ediofy/media/edit", "ediofy/links/new", "ediofy/links/edit", "ediofy/questions/new", "ediofy/questions/edit"].include?("#{params[:controller]}/#{params[:action]}")
    return "learn" if params[:controller] == "ediofy/dashboard"
    return "groups" if params[:controller] == "ediofy/groups"
  end
  def rescue_image_tag(file, class_name, version, options={})
    begin
      image_tag file.url(version.to_sym), options
    rescue
      image_tag "ediofy/#{class_name}_#{version.to_s}.jpg", options
    end
  end
  def link_to_url(url, *args)
    begin
      u = URI.parse(url)
      if !u.scheme
        # prepend http:// and link it
        link_to url, "http://#{url}}", *args
      elsif(%w{http https}.include?(u.scheme))
        # JUST LINK IT
        link_to url.sub(/http:\/\/|https:\/\//, ''), url, *args
      else
        # link nothing
        ''
      end
    rescue
      ''
    end
  end

  def nested_tags(tags, f, prechecked = true)
    tags.map do |tag, sub_tags|
      render(template: 'ediofy/tags/_tag', locals: { tag: tag, sub_tags: sub_tags, f: f, prechecked: prechecked })
    end.join.html_safe
  end
  def navigation_link_to(*args, &block)
    options = args.extract_options!
    options[:class] &&= options[:class].split /\s+/ unless options[:class].is_a? Array
    options[:class] ||= []
    options[:class] << 'selected' if current_page? args.last
    args << options
    link_to *args, &block
  end
   # Used to shorten and sanitize user entered HTML text blocks.
  def truncate_html html, length = 120
    if html.present?
      truncate strip_tags(html).gsub(/&nbsp;/i, ' '), length: length, separator: ' '
    end
  end

  #main image for facebook sharing
  def og_image_path
    image_url('ediofy/main_og_img.png')
  end

  def hide_footer_class
    if (controller_name == 'follows' or controller_name == 'interests') and action_name == 'index'
      'opacity00'
    end
  end

  def content_type_select(selected = nil, remote = true)
    select_tag(
      :content_type,
      options_for_select(
        {
          'All Content' => '',
          'Images' => :image,
          'Videos' => :video,
          'Audio' => :audio,
          'Questions' => :questions,
          'Conversations' => :conversations,
          'PDFs' => :pdf,
        },
        selected || params[:content_type]
      ),
      class: 'form-control content_type_select select-down',
      data: { remote: remote }
    )
  end

  def sort_by_select(id = :sort_by, remote = true)
    select_tag(id,
               options_for_select(
                 {'Latest' => :latest,
                   'Top Rated' => :top_rated,
                    'Most Popular' => :most_popular,
                    'Trending' => :trending}, 
                    params[:sort_by],
                    ), class: 'form-control sort_by_select select-down',
                data: {remote: remote }
              
              )
  end

  def group_type_select(selected = nil, remote = false)
    select_tag(:group_type,
               options_for_select({'All Groups' => '', 'Public Groups' => :public,
                                   'Private Groups' => :private},
                                  selected || params[:isPublic]), class: 'form-control group_type_select select-down')
  end

  def opts_for_select_cpd_time_range
    opts_for_select = [
      ['this week', 'week'],
      ['this month', 'month'],
      ['this year', 'year'],
      ['all time', 'alltime']
    ]

    return opts_for_select
  end



  def sort_group_by_select(id = :group_sort_by, remote = true)
    select_tag(id,
               options_for_select({'Latest' => :latest, 'Most Popular' => :most_popular}, params[:sort_by]), class: 'form-control sort_by_select select-down',
               )
  end

  def media_type(file)
    if file.present? && !file.media_type.blank?
      file.media_type.capitalize
    else
      'Media'
    end
  end

  def humanize_seconds(secs)
    [[60, :secs], [60, :mins], [24, :hrs], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i}#{name}" if n.to_i > 0
      end
    }.compact.reverse.join(' ')
  end

  def serialized_comment(txt)
    html_doc = Nokogiri::HTML::fragment txt
    spans = html_doc.search("span.atwho-inserted")
    mentions = spans.blank? ? [] : spans.text.split("@").select{|u| !u.blank? }
    unless mentions.empty?
      spans.each do |s|
        user = User.find_by(username: (s.text).remove("@") )
        unless user.blank?
          s.content = ""
          s.add_child(link_to user.full_name.to_s.titleize, ediofy_user_path(user), target: "_blank")
        end
      end
      html_doc.to_html
    else
      txt
    end
  end


  def default_placeholder resource_name, resource_id, version
    placeholder = DefaultPlaceholder.find_by(placeholderable_id: resource_id,placeholderable_type: resource_name)
    if placeholder.blank?
      number_between_1_11 = rand(1..11)
      DefaultPlaceholder.create(number: number_between_1_11, placeholderable_id: resource_id,placeholderable_type: resource_name)
    else
      number_between_1_11 = placeholder.number
    end
    "placeholders/placeholder-#{version}-#{number_between_1_11}.jpg"
  end

  def google_analytics
    html = <<-HTML
      <!-- Global site tag (gtag.js) - Google Analytics -->
      <script async src="https://www.googletagmanager.com/gtag/js?id=#{ENV['GOOGLE_ANALYTICS_KEY']}"></script>
      <script>
      window.dataLayer = window.dataLayer || [];
      function gtag()
      {dataLayer.push(arguments);}

      gtag('js', new Date());

      gtag('config', "#{ENV['GOOGLE_ANALYTICS_KEY']}");
      </script>
    HTML

    html.html_safe
  end

  def is_mobile?
    request.user_agent =~ /Mobile|webOS/
  end

end
