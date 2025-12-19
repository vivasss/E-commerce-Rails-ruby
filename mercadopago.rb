Mercadopago.configure do |config|
  config.access_token = ENV["MERCADOPAGO_ACCESS_TOKEN"]
end

Rails.configuration.mercadopago = {
  public_key: ENV["MERCADOPAGO_PUBLIC_KEY"],
  access_token: ENV["MERCADOPAGO_ACCESS_TOKEN"]
}
