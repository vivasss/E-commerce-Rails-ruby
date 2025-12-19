FriendlyId.defaults do |config|
  config.use :reserved
  config.reserved_words = %w[new edit index session login logout users admin]
  
  config.use :finders
  
  config.use :slugged
  
  config.slug_column = "slug"
  
  config.sequence_separator = "--"
end
