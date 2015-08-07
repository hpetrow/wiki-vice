class ChangePageidtoPageIdOnPages < ActiveRecord::Migration
  def change
    rename_column :pages, :pageid, :page_id
  end
end
