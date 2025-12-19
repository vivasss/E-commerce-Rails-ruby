puts "Criando usuario admin..."

admin = User.find_or_create_by!(email: "admin@elixer.com.br") do |user|
  user.name = "Administrador"
  user.password = "admin123"
  user.password_confirmation = "admin123"
  user.role = :admin
  user.skip_confirmation!
end

puts "Admin criado: #{admin.email}"

puts "Criando categorias..."

categories_data = [
  { name: "Eletronicos", description: "Produtos eletronicos e gadgets" },
  { name: "Roupas", description: "Vestuario masculino e feminino" },
  { name: "Casa e Decoracao", description: "Itens para sua casa" },
  { name: "Esportes", description: "Equipamentos esportivos" },
  { name: "Livros", description: "Livros e e-books" }
]

categories = categories_data.map do |data|
  Category.find_or_create_by!(name: data[:name]) do |cat|
    cat.description = data[:description]
    cat.active = true
  end
end

puts "#{categories.count} categorias criadas"

subcategories_data = [
  { name: "Smartphones", parent: "Eletronicos" },
  { name: "Notebooks", parent: "Eletronicos" },
  { name: "Acessorios", parent: "Eletronicos" },
  { name: "Camisetas", parent: "Roupas" },
  { name: "Calcas", parent: "Roupas" },
  { name: "Calcados", parent: "Roupas" },
  { name: "Moveis", parent: "Casa e Decoracao" },
  { name: "Iluminacao", parent: "Casa e Decoracao" }
]

subcategories_data.each do |data|
  parent = Category.find_by(name: data[:parent])
  Category.find_or_create_by!(name: data[:name]) do |cat|
    cat.parent = parent
    cat.active = true
  end
end

puts "Subcategorias criadas"

puts "Criando produtos..."

products_data = [
  {
    name: "iPhone 15 Pro",
    category: "Smartphones",
    base_price: 8999.00,
    compare_at_price: 9999.00,
    description: "O mais avancado iPhone com chip A17 Pro",
    variants: [
      { name: "128GB - Titanio Natural", price: 8999.00, stock: 50 },
      { name: "256GB - Titanio Natural", price: 9999.00, stock: 30 },
      { name: "512GB - Titanio Preto", price: 11999.00, stock: 20 }
    ]
  },
  {
    name: "MacBook Pro 14",
    category: "Notebooks",
    base_price: 15999.00,
    description: "Notebook profissional com chip M3",
    variants: [
      { name: "M3 - 8GB - 512GB", price: 15999.00, stock: 25 },
      { name: "M3 Pro - 18GB - 512GB", price: 21999.00, stock: 15 }
    ]
  },
  {
    name: "Camiseta Basica Algodao",
    category: "Camisetas",
    base_price: 49.90,
    description: "Camiseta 100% algodao, confortavel para o dia a dia",
    variants: [
      { name: "P - Branca", price: 49.90, stock: 100 },
      { name: "M - Branca", price: 49.90, stock: 150 },
      { name: "G - Branca", price: 49.90, stock: 120 },
      { name: "P - Preta", price: 49.90, stock: 100 },
      { name: "M - Preta", price: 49.90, stock: 150 },
      { name: "G - Preta", price: 49.90, stock: 120 }
    ]
  },
  {
    name: "Tenis Running Pro",
    category: "Calcados",
    base_price: 299.90,
    compare_at_price: 399.90,
    description: "Tenis para corrida com amortecimento avancado",
    variants: [
      { name: "38 - Preto", price: 299.90, stock: 40 },
      { name: "39 - Preto", price: 299.90, stock: 45 },
      { name: "40 - Preto", price: 299.90, stock: 50 },
      { name: "41 - Preto", price: 299.90, stock: 45 },
      { name: "42 - Preto", price: 299.90, stock: 40 }
    ]
  },
  {
    name: "Luminaria LED Moderna",
    category: "Iluminacao",
    base_price: 189.90,
    description: "Luminaria de mesa LED com controle de intensidade",
    variants: [
      { name: "Branca", price: 189.90, stock: 60 },
      { name: "Preta", price: 189.90, stock: 55 }
    ]
  }
]

products_data.each do |data|
  category = Category.find_by(name: data[:category])
  next unless category
  
  product = Product.find_or_create_by!(name: data[:name]) do |p|
    p.category = category
    p.base_price = data[:base_price]
    p.compare_at_price = data[:compare_at_price]
    p.description = data[:description]
    p.short_description = data[:description][0..100]
    p.active = true
    p.featured = rand < 0.3
  end
  
  data[:variants].each_with_index do |variant_data, index|
    ProductVariant.find_or_create_by!(product: product, name: variant_data[:name]) do |v|
      v.sku = "#{product.name.parameterize.upcase[0..5]}-#{SecureRandom.hex(3).upcase}"
      v.price = variant_data[:price]
      v.stock_quantity = variant_data[:stock]
      v.active = true
      v.position = index
    end
  end
end

puts "Produtos criados"

puts "Criando cupons..."

coupons_data = [
  { code: "BEMVINDO10", discount_type: :percentage, discount_value: 10, description: "10% de desconto para novos clientes" },
  { code: "FRETEGRATIS", discount_type: :free_shipping, discount_value: 1, minimum_amount: 100, description: "Frete gratis em compras acima de R$100" },
  { code: "DESCONTO50", discount_type: :fixed_amount, discount_value: 50, minimum_amount: 200, description: "R$50 de desconto em compras acima de R$200" }
]

coupons_data.each do |data|
  Coupon.find_or_create_by!(code: data[:code]) do |c|
    c.discount_type = data[:discount_type]
    c.discount_value = data[:discount_value]
    c.minimum_amount = data[:minimum_amount]
    c.description = data[:description]
    c.active = true
    c.starts_at = Time.current
    c.expires_at = 1.year.from_now
  end
end

puts "Cupons criados"

puts "Seed concluido com sucesso!"
