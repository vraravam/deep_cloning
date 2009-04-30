class Pirate < ActiveRecord::Base
  has_many :mateys
  has_many :treasures
  has_many :gold_pieces, :through => :treasures
  has_one :parrot
  has_and_belongs_to_many :pirates_unions
end