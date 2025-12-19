class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :number, null: false
      t.integer :status, default: 0, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.decimal :shipping_amount, precision: 10, scale: 2, default: 0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false
      t.references :coupon, type: :uuid, foreign_key: true
      t.text :notes
      t.text :admin_notes
      t.string :shipping_name
      t.string :shipping_street
      t.string :shipping_number
      t.string :shipping_complement
      t.string :shipping_neighborhood
      t.string :shipping_city
      t.string :shipping_state
      t.string :shipping_postal_code
      t.string :shipping_country
      t.string :shipping_phone
      t.string :billing_name
      t.string :billing_street
      t.string :billing_number
      t.string :billing_complement
      t.string :billing_neighborhood
      t.string :billing_city
      t.string :billing_state
      t.string :billing_postal_code
      t.string :billing_country
      t.string :billing_phone
      t.datetime :confirmed_at
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.datetime :cancelled_at
      t.string :cancellation_reason
      
      t.timestamps
    end
    
    add_index :orders, :number, unique: true
    add_index :orders, :status
    add_index :orders, :created_at
    add_index :orders, [:user_id, :status]
  end
end
