class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.integer :address_type, default: 0, null: false
      t.string :name, null: false
      t.string :street, null: false
      t.string :number, null: false
      t.string :complement
      t.string :neighborhood, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :postal_code, null: false
      t.string :country, default: "BR", null: false
      t.string :phone
      t.boolean :default, default: false, null: false
      
      t.timestamps
    end
    
    add_index :addresses, [:user_id, :address_type]
    add_index :addresses, [:user_id, :default]
  end
end
