class Revision < ActiveRecord::Base
  belongs_to :page
  belongs_to :author
  delegate :categories, to: :page
end
