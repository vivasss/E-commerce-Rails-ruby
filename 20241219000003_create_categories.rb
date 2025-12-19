class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.references :parent, type: :uuid, foreign_key: { to_table: :categories }
      t.integer :position, default: 0
      t.boolean :active, default: true, null: false
      t.string :meta_title
      t.text :meta_description
      
      t.timestamps
    end
    
    add_index :categories, :slug, unique: true
    add_index :categories, :active
    add_index :categories, :position
  end
end
