class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items, id: :uuid do |t|
      t.references :cart, type: :uuid, null: false, foreign_key: true
      t.references :product_variant, type: :uuid, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      
      t.timestamps
    end
    
    add_index :cart_items, [:cart_id, :product_variant_id], unique: true
  end
end
