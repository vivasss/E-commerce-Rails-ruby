class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false
      t.string :name, null: false
      t.string :phone
      t.integer :role, default: 0, null: false
      t.string :provider
      t.string :uid
      t.string :avatar_url
      t.boolean :active, default: true, null: false
      
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      
      t.timestamps
    end
    
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, [:provider, :uid], unique: true
    add_index :users, :role
    add_index :users, :active
  end
end
