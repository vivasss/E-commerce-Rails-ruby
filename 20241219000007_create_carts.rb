class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true
      t.string :session_id
      t.datetime :expires_at
      
      t.timestamps
    end
    
    add_index :carts, :session_id, unique: true, where: "session_id IS NOT NULL"
    add_index :carts, :expires_at
  end
end
