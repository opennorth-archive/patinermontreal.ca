# coding: utf-8
class Arrondissement < ActiveRecord::Base
  has_many :patinoires

  validates_presence_of :nom_arr
  validates_presence_of :date_maj, if: :cle?
  validates_uniqueness_of :nom_arr
  validates_uniqueness_of :cle, allow_blank: true

  before_save :set_cle

  scope :nongeocoded, where(lat: nil)
  scope :geocoded, where('lat IS NOT NULL')

private

  def set_cle
    if nom_arr
      self.cle = {
        'Côte-des-Neiges—Notre-Dame-de-Grâce' => 'cdn',
        'Le Plateau-Mont-Royal' => 'pmr',
        'Rivière-des-Prairies—Pointe-aux-Trembles' => 'rdp',
        'Rosemont—La Petite-Patrie' => 'rpp',
        'Mercier—Hochelaga-Maisonneuve' => 'mhm',
        'Ahuntsic—Cartierville' => 'ahc',
        'Le Sud-Ouest' => 'sou',
        'Villeray—Saint-Michel—Parc-Extension' => 'vsp',
        'Ville-Marie' => 'vma',
      }[nom_arr]
    end
  end
end
