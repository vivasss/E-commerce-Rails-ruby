class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :order, type: :uuid, null: false, foreign_key: true
      t.integer :gateway, default: 0, null: false
      t.string :gateway_payment_id
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :status, default: 0, null: false
      t.string :payment_method
      t.datetime :paid_at
      t.datetime :refunded_at
      t.decimal :refund_amount, precision: 10, scale: 2
      t.string :refund_reason
      t.jsonb :metadata, default: {}
      t.text :error_message
      
      t.timestamps
    end
    
    add_index :payments, :gateway_payment_id
    add_index :payments, :status
    add_index :payments, :gateway
  end
end
