class RemoveTimeFromRevisions < ActiveRecord::Migration
  def change
    remove_column :revisions, :time
  end
end
