class Author < ActiveRecord::Base
  has_many :revisions
  has_many :pages, :through => :revisions
  WIKI = WikiWrapper.new

  def top_contributions
    # Returns the pages that the author has contributed to the most
    # and the amount of contributions he has made to that page
    WIKI.get_user_contributions(self) if self.unique_pages.size == 1
    Revision.includes(:author, :page).where(authors: {id: self.id}).group(:title).order("count_id DESC").count.take(5)
  end

  def most_recent_revision
    revision = self.revisions.order("timestamp desc").limit(1).first
    if revision.content.nil?
      WIKI.get_revision_content(revision)
    end
    revision
  end

  def unique_pages
    self.pages.uniq
  end

end
