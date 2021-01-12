source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.3.1'

gem 'rails', '~> 5.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
# gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'roadie' # Inline styles for mailers.

group :staging, :development do
  gem 'rack-dev-mark'
end

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'puma', '~> 3.9.1'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'factory_bot_rails'
  gem 'pry-rails'
  gem 'pry-rescue'
end
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'foreman'
  gem 'rails_layout'
  gem 'letter_opener'
  gem 'rubocop-rails'
end
group :test do
  gem 'database_cleaner'
  gem 'simplecov', require: false
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'bootstrap-sass'
gem 'jquery-slick-rails'
gem 'binding_of_caller'

# Layouts, Forms and Styling
gem 'haml-rails'
gem 'font-awesome-rails'
gem 'formtastic'
# gem 'formtastic-bootstrap'
gem 'nested_form_fields'
# gem 'rails-jquery-tokeninput'
# gem 'page_title_helper'
gem 'country-select', git: 'git://github.com/jamesds/country-select.git'

# Flash responder
gem 'responders'

# Authentication
gem 'devise'
gem 'devise_token_auth', '>= 0.1.40'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-linkedin'
gem 'omniauth-google-oauth2'
gem 'pnotify-rails'
gem 'unobtrusive_flash', '>=3'
gem 'metainspector'

# Attachments!
gem 'mini_magick', '~> 4.3', '>= 4.3.6'
gem 'carrierwave'
gem 'carrierwave_backgrounder'
gem 'resque'
gem 'rmagick','2.16.0'
gem 'fog'
gem 'open_uri_redirections'

gem 'pg'
gem 'therubyracer', :platform=>:ruby
gem 'wysiwyg-rails'

gem 'activeadmin'
# gem 'mina'
gem 'mina-multistage', require: false
gem 'dotenv-rails'

gem 'html5sortable-rails'

# Activerecord extensions
gem 'acts_as_list'
gem 'acts_as_commentable'
gem 'acts_as_votable'
gem 'acts_as_follower', github: 'tcocca/acts_as_follower', branch: 'master'
# gem 'has_machine_tags'#, "0.2.0", git: 'https://github.com/olance/has_machine_tags.git'
gem 'acts-as-taggable-on', '~> 6.0'
gem 'rakismet'
gem 'globalize', git: 'https://github.com/globalize/globalize'
gem 'ancestry'
# gem 'mina-hipchat'
gem 'kaminari'
gem 'isotope-rails'
gem 'rails-observers'
gem 'mail'
gem 'apipie-rails'

gem 'amoeba'
gem 'select2-rails', '~> 4.0.3'
gem 'activeadmin-select2', github: 'mfairburn/activeadmin-select2'

gem 'jquery-infinite-pages'
gem 's3_direct_upload'
gem 'aws-sdk', '< 2.0'
gem 'jquery-atwho-rails'
gem 'bootbox-rails', '~>0.4'
gem 'airbrake', '~> 7.3'
# gem 'intercom-rails'
gem 'resque-scheduler'
gem 'pdf-reader'
gem 'mediainfo'
gem 'bootstrap-datepicker-rails'
gem 'wicked_pdf'
gem 'flatpickr'
