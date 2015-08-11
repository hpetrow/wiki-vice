class RevisionParser
  attr_accessor :html_content

  def initialize(revision)
    @html_content = Nokogiri::HTML(revision.content)
  end

  def line_number
    html_content.css(".diff-lineno").first.text.gsub(":", "")
  end

  def context
    html_content.css(".diff-context").text
  end

  def deleted_line
    html_content.css(".diff-deletedline").text
  end

  def added_line
    html_content.css(".diff-addedline").text
  end

  def diff_change
    @html_content.css(".diffchange")
  end

  def change_context
    @html_content.css(".diffchange").first.parent
  end

  def change_type
    self.change_context.parent.attr('class') == 'diff-deletedline' ? 'Deleted Line' : 'Added Line'
  end

  def parse_change
    result = "#{self.change_context}".gsub("&lt;", "<").gsub("&gt", ">")
    result = result.gsub(/({{)|(}})|(\[\[)|(]])/, " ")
    result.gsub(/(<ref[^<]+<\/ref>;)/, "").html_safe
  end
end
