class AddSizeToRevisions < ActiveRecord::Migration
  def change
    add_column :revisions, :size, :integer
    add_column :revisions, :size_diff, :integer
  end
end
