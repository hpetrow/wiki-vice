class ReaddPageidToPages < ActiveRecord::Migration
  def change
    add_column :pages, :page_id, :integer
  end
end
