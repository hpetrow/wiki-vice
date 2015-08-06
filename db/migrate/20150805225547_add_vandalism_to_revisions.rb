class AddVandalismToRevisions < ActiveRecord::Migration
  def change
    add_column :revisions, :vandalism, :boolean
  end
end
