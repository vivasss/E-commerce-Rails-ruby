class CreateWishlistItems < ActiveRecord::Migration[7.1]
  def change
    create_table :wishlist_items, id: :uuid do |t|
      t.references :wishlist, type: :uuid, null: false, foreign_key: true
      t.references :product, type: :uuid, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :wishlist_items, [:wishlist_id, :product_id], unique: true
  end
end
