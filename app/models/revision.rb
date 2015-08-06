class Revision < ActiveRecord::Base
  belongs_to :page
  belongs_to :author
  delegate :categories, to: :page

  def get_date
    formatted_date = '%m-%d-%Y %H:%M:%S %Z'
    DateTime.parse(self.time,formatted_date).to_formatted_s(:long)
  end
end
