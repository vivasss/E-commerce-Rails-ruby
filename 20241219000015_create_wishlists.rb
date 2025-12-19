class CreateWishlists < ActiveRecord::Migration[7.1]
  def change
    create_table :wishlists, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :name, default: "Minha Lista de Desejos"
      
      t.timestamps
    end
    
    add_index :wishlists, [:user_id, :name], unique: true
  end
end
