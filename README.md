# Elixer E-commerce

Plataforma de e-commerce moderna construida com Ruby on Rails 7.

## Requisitos

- Ruby 3.2.2
- PostgreSQL 15+
- Redis 7+
- Node.js 18+

## Instalacao

### Com Docker (recomendado)

```bash
docker-compose up -d
docker-compose exec web rails db:create db:migrate db:seed
```

### Instalacao Local

```bash
bundle install
rails db:create db:migrate db:seed
```

## Configuracao

Copie o arquivo de variaveis de ambiente:

```bash
cp .env.example .env
```

Configure as seguintes variaveis:

- `POSTGRES_*`: Credenciais do banco de dados
- `REDIS_URL`: URL do Redis
- `STRIPE_*`: Credenciais do Stripe
- `MERCADOPAGO_*`: Credenciais do Mercado Pago
- `GOOGLE_*`: OAuth Google
- `FACEBOOK_*`: OAuth Facebook

## Executando

### Desenvolvimento

```bash
rails server
```

### Sidekiq (processamento de jobs)

```bash
bundle exec sidekiq
```

## Estrutura do Projeto

```
app/
  controllers/
    admin/        # Painel administrativo
    api/v1/       # API REST
    users/        # Autenticacao
  models/         # ActiveRecord models
  services/       # Service objects
    catalog/      # Busca e filtros
    cart/         # Carrinho
    checkout/     # Finalizacao de compra
    payments/     # Gateways de pagamento
    reports/      # Relatorios
  jobs/           # Background jobs
  mailers/        # Emails transacionais
```

## Testes

```bash
bundle exec rspec
```

## Funcionalidades

- Autenticacao com Devise + OAuth2 (Google, Facebook)
- Catalogo de produtos com variantes
- Busca full-text com pg_search
- Carrinho persistente
- Checkout multi-etapas
- Integracoes de pagamento (Stripe, Mercado Pago)
- Gestao de pedidos com maquina de estados
- Cupons de desconto
- Avaliacoes de produtos
- Lista de desejos
- Painel administrativo completo
- Relatorios de vendas, estoque e clientes
- API REST para integracao

## Credenciais Padrao

Admin: admin@elixer.com.br / admin123
