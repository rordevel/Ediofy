CarrierWave::Backgrounder.configure do |c|
  # c.backend :delayed_job, queue: :carrierwave
  c.backend :resque, queue: "#{Rails.env}_store_asset"
  # c.backend :sidekiq, queue: :carrierwave
  # c.backend :girl_friday, queue: :carrierwave
  # c.backend :qu, queue: :carrierwave
  # c.backend :qc
end
