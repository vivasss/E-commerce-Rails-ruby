class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons, id: :uuid do |t|
      t.string :code, null: false
      t.integer :discount_type, default: 0, null: false
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.decimal :minimum_amount, precision: 10, scale: 2
      t.decimal :maximum_discount, precision: 10, scale: 2
      t.integer :usage_limit
      t.integer :usage_count, default: 0, null: false
      t.integer :per_user_limit, default: 1
      t.datetime :starts_at
      t.datetime :expires_at
      t.boolean :active, default: true, null: false
      t.text :description
      
      t.timestamps
    end
    
    add_index :coupons, :code, unique: true
    add_index :coupons, :active
    add_index :coupons, :expires_at
  end
end
