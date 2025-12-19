MoneyRails.configure do |config|
  config.default_currency = :brl
  config.rounding_mode = BigDecimal::ROUND_HALF_UP
  
  config.default_format = {
    no_cents_if_whole: false,
    symbol: "R$",
    sign_before_symbol: true
  }
end
