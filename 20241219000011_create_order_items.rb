class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items, id: :uuid do |t|
      t.references :order, type: :uuid, null: false, foreign_key: true
      t.references :product_variant, type: :uuid, null: false, foreign_key: true
      t.references :product, type: :uuid, null: false, foreign_key: true
      t.string :product_name, null: false
      t.string :variant_name, null: false
      t.string :sku, null: false
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      
      t.timestamps
    end
  end
end
