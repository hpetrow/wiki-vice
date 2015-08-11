class Category < ActiveRecord::Base
  belongs_to :page
  validates :title, uniqueness: true
end
