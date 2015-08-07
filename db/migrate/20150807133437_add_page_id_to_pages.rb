class AddPageIdToPages < ActiveRecord::Migration
  def change
    remove_column :pages, :page_id, :integer
  end
end
