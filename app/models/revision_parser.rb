class RevisionParser
  attr_accessor :html_content, :diff_type

  REFERENCE = {
    "[[]]" => "== link ==",
    "{{}}" => "== reference ==",
    "" => "== white space =="
  }

  def parse(content)
    @html_content = Nokogiri::HTML(content)
    @diff_type = self.set_diff_type
  end

  def line_number
    html_content.css(".diff-lineno").first.text.gsub(":", "")
  end

  def context
    html_content.css(".diff-context")
  end

  def reference(diff)
    if REFERENCE.has_key?(diff.text.strip)
      REFERENCE[diff.text.strip]
    else
      diff
    end
  end

  def deleted_line
    html_content.css(".diff-deletedline")
  end

  def added_line
    html_content.css('.diff-addedline')
  end

  def diff_change
    html_content.css(".diffchange")
  end

  def diff_change_type
    diff = diff_change
    if (diff.length > 1)
      first_type = get_diff_change_type(diff.first)
      last_type = get_diff_change_type(diff.last)
      first_type == last_type ? first_type : "#{first_type}/#{last_type}"
    else
      get_diff_change_type(diff.first)
    end
  end

  def get_diff_change_type(diff)
    diff.parent.parent.attr('class') == 'diff-deletedline' ? 'Deleted' : 'Added'
  end

  def set_diff_type
    if !diff_change.empty?
      :diff_change
    elsif !added_line.empty?
      :added_line
    elsif !deleted_line.empty?
      :deleted_line
    end
  end

  def get_diff_type
    types = {
      added_line: "Added",
      deleted_line: "Deleted"
    }
    diff_type == :diff_change ? self.diff_change_type : types[diff_type]
  end

  def diff_html
    preprocessed_diff = reference(self.send(diff_type))
    "<p>#{line_number}</p><p>#{get_diff_type}</p> #{parse_diff(preprocessed_diff)}"
  end

  def parse_diff(diff)
    result = "#{diff}".gsub("&lt;", "<").gsub("&gt", ">")
    result = result.gsub(/({{)|(}})|(\[\[)|(\]\])/, " ")
    result.gsub(/(<ref[^<]+<\/ref>;)/, "")
  end
end
