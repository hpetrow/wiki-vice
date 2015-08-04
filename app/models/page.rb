class Page < ActiveRecord::Base
  has_many :revisions
  has_many :authors, :through => :revisions

  def top_five_authors
    Revision.find_by_sql(
      ["SELECT revisions.id AS revision_id, revisions.page_id AS page_id, 
        revisions.author_id AS author_id, COUNT(*) AS author_id_count, 
        authors.name AS author_name 
        FROM revisions 
        INNER JOIN authors ON revisions.author_id = authors.id 
        WHERE revisions.page_id = ? 
        GROUP BY revisions.author_id 
        ORDER BY author_id_count DESC 
        LIMIT 5", self.id]).collect{|rev| rev.author}
  end
end
