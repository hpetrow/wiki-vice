class RevisionParser
  attr_accessor :html_content

  def parse_content(content)
    @html_content = Nokogiri::HTML(content)
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
end
