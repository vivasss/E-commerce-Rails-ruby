class CreateCouponUsages < ActiveRecord::Migration[7.1]
  def change
    create_table :coupon_usages, id: :uuid do |t|
      t.references :coupon, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :order, type: :uuid, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :coupon_usages, [:coupon_id, :user_id]
  end
end
