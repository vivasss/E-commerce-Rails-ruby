class CreateProductVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :product_variants, id: :uuid do |t|
      t.references :product, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :sku, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :compare_at_price, precision: 10, scale: 2
      t.integer :stock_quantity, default: 0, null: false
      t.string :option1_name
      t.string :option1_value
      t.string :option2_name
      t.string :option2_value
      t.string :option3_name
      t.string :option3_value
      t.decimal :weight, precision: 8, scale: 3
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0
      
      t.timestamps
    end
    
    add_index :product_variants, :sku, unique: true
    add_index :product_variants, :stock_quantity
    add_index :product_variants, :active
    add_index :product_variants, [:product_id, :position]
  end
end
