class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.text :short_description
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.decimal :base_price, precision: 10, scale: 2, null: false
      t.decimal :compare_at_price, precision: 10, scale: 2
      t.string :sku
      t.boolean :active, default: true, null: false
      t.boolean :featured, default: false, null: false
      t.string :meta_title
      t.text :meta_description
      t.decimal :average_rating, precision: 3, scale: 2, default: 0
      t.integer :reviews_count, default: 0
      t.integer :total_sold, default: 0
      
      t.timestamps
    end
    
    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true, where: "sku IS NOT NULL"
    add_index :products, :active
    add_index :products, :featured
    add_index :products, :base_price
    add_index :products, :created_at
    add_index :products, :average_rating
    add_index :products, :total_sold
  end
end
