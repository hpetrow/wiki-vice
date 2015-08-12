class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.text :content
      t.integer :revid
      t.text :comment
      t.datetime :timestamp
      t.boolean :vandalism
      t.integer :page_id
      t.integer :author_id

      t.timestamps null: false
    end
  end
end
