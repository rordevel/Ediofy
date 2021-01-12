require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ediofy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.rakismet.key = '79d76b7408b2'
    config.rakismet.url = 'http://gmep.imeducate.com/'
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << "#{config.root}/app/observers"
    config.autoload_paths << "#{config.root}/lib"
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
    # Activate observers that should always be running.
    config.active_record.observers = [
        :level_badge_observer,
        :media_file_observer,
        :points_badge_observer,
        :questions_answered_badge_observer,
        :questions_submitted_badge_observer,
        :questions_voted_badge_observer,
        :user_activity_observer,
        :question_activity_observer
    ]
  end
end
