class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.datetime :time
      t.text :content
      t.integer :lines
      t.integer :page_id
      t.integer :author_id

      t.timestamps null: false
    end
  end
end
