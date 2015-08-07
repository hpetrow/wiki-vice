class RenameCategoryNameToTitle < ActiveRecord::Migration
  def change
    remove_column :categories, :title
    add_column :categories, :title, :string
  end
end
