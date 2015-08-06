class Revision < ActiveRecord::Base
  belongs_to :page
  belongs_to :author
  delegate :categories, to: :page

  def get_date
    formatted_date = '%m-%d-%Y %H:%M:%S %Z'
    DateTime.parse(self.timestamp.to_s, formatted_date).to_formatted_s(:long_ordinal)
  end
end
