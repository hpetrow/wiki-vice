class AddPageIdToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :page_id, :integer
  end
end
