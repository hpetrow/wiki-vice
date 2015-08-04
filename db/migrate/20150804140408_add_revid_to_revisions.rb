class AddRevidToRevisions < ActiveRecord::Migration
  def change
    add_column :revisions, :revid, :integer
  end
end
