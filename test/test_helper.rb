require 'simplecov'

SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/test/'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class CarrierWave::Mount::Mounter
  def store!
    # Not storing uploads in the tests
  end
end

class MediaFile < ActiveRecord::Base
  def upload_to_s3_or_transcode
    # Skip upload to S3
  end
end

module Notifiable
  def self.included
    # prevent common notification error (fatal: No live threads left. Deadlock?)
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  # Add more helper methods to be used by all tests here...
end
