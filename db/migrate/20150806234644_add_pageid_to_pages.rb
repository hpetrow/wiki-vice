class AddPageidToPages < ActiveRecord::Migration
  def change
    add_column :pages, :pageid, :integer
  end
end
