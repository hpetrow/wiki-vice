class RemoveEditCountFromAuthors < ActiveRecord::Migration
  def change
    remove_column :authors, :edit_count
    remove_column :authors, :url
  end
end
