class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :name
      t.integer :edit_count
      t.string :url
      t.boolean :anonymous

      t.timestamps null: false
    end
  end
end
