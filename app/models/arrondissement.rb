class Arrondissement < ActiveRecord::Base
  has_many :patinoires

  validates_presence_of :nom_arr, :cle, :date_maj
  validates_uniqueness_of :nom_arr, :cle
end
