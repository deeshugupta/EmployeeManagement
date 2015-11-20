Airbrake.configure do |config|
  config.api_key = '8a087a9ce2a8bdaa3745379c6e8699fa'
  config.host    = 'my-errors.herokuapp.com'
  config.port    = 443
  config.secure  = config.port == 443
  # config.development_environments = []
  # config.ignore_only = []
end
