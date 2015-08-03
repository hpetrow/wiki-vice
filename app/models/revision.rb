class Revision < ActiveRecord::Base
  belongs_to :page
  belongs_to :author
end
