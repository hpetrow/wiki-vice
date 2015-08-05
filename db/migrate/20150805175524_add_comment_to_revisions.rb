class AddCommentToRevisions < ActiveRecord::Migration
  def change
    add_column :revisions, :comment, :string
  end
end
