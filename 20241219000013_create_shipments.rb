class CreateShipments < ActiveRecord::Migration[7.1]
  def change
    create_table :shipments, id: :uuid do |t|
      t.references :order, type: :uuid, null: false, foreign_key: true
      t.string :carrier
      t.string :tracking_number
      t.string :tracking_url
      t.integer :status, default: 0, null: false
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.string :shipping_method
      t.decimal :cost, precision: 10, scale: 2
      t.decimal :weight, precision: 8, scale: 3
      t.jsonb :metadata, default: {}
      
      t.timestamps
    end
    
    add_index :shipments, :tracking_number
    add_index :shipments, :status
  end
end
