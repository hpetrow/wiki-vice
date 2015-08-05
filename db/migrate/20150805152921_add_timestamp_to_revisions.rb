class AddTimestampToRevisions < ActiveRecord::Migration
  def change
    add_column :revisions, :timestamp, :datetime
  end
end
