class Author < ActiveRecord::Base
  has_many :revisions
  has_many :pages, :through => :revisions
end
