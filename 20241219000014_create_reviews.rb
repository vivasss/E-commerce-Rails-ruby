class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :product, type: :uuid, null: false, foreign_key: true
      t.integer :rating, null: false
      t.string :title
      t.text :body
      t.boolean :approved, default: false, null: false
      t.boolean :verified_purchase, default: false, null: false
      t.datetime :approved_at
      
      t.timestamps
    end
    
    add_index :reviews, [:product_id, :approved]
    add_index :reviews, [:user_id, :product_id], unique: true
    add_index :reviews, :rating
  end
end
