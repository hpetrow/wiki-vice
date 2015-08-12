class RevisionParser
  attr_accessor :html_content

  def parse(revision)
    @html_content = Nokogiri::HTML(revision.content)
  end

  def line_number
    html_content.css(".diff-lineno").first.text.gsub(":", "")
  end

  def context
    html_content.css(".diff-context")
  end

  def deleted_line
    html_content.css(".diff-deletedline")
  end

  def added_line
    html_content.css(".diff-addedline")
  end

  def diff_change
    html_content.css(".diffchange")
  end

  def diff_change_context
    html_content.css(".diffchange").first.parent
  end

  def diff_change_type
    diff_change_context.parent.attr('class') == 'diff-deletedline' ? 'Deleted Line' : 'Added Line'
  end

  def change
    if !diff_change.empty?
      "#{diff_change_type} #{parse_change(diff_change_context)}"
    elsif !added_line.empty?
      "Added Line #{parse_change(added_line)}"
    elsif !deleted_line.empty?
      "Deleted Line #{parse_change(delete_line)}"
    else
      ""
    end
  end

  def parse_change(change)
    result = "#{change}".gsub("&lt;", "<").gsub("&gt", ">")
    result = result.gsub(/({{)|(}})|(\[\[)|(]])/, " ")
    result.gsub(/(<ref[^<]+<\/ref>;)/, "")
  end
end
