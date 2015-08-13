class Revision < ActiveRecord::Base
  belongs_to :page
  belongs_to :author
  has_many :vandalisms
  delegate :categories, to: :page
  validates :revid, uniqueness: true

  def get_date
    formatted_date = '%m-%d-%Y %H:%M:%S %Z'
    DateTime.parse(self.timestamp.to_s, formatted_date).to_formatted_s(:long_ordinal)
  end

  # def with_content
  #   self.content = WikiWrapper.new.revision_content(self) if !self.content
  #   self.save
  #   self
  # end

  def get_content
    if !self.content
      self.content = parse_wiki_content
      self.save
    end
    self.content
  end

  def parse_wiki_content
    content = get_content_from_wiki
    if (content != "")
      parser = RevisionParser.new
      parser.parse(content)
      parser.diff_html
    else
      ""
    end
  end

  def parse_diff_content
    parser = RevisionParser.new
    parser.parse(self.get_content)
    parser.diff_change.text
  end

  def get_content_from_wiki
    WikiWrapper.new.revision_content(self)
  end


end
