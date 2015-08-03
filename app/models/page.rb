class Page < ActiveRecord::Base
  has_many :revisions
  has_many :authors, :through => :revisions
end
