# coding: utf-8
class Patinoire < ActiveRecord::Base
  belongs_to :arrondissement

  validates_presence_of :nom, :description, :genre, :parc, :slug, :source, :arrondissement_id
  validates_uniqueness_of :nom, scope: :arrondissement_id
  validates_inclusion_of :description, in: [
      'Anneau de glace',
      'Aire de patinage libre',
      'Grande patinoire de hockey',
      'Grande patinoire avec bandes',
      'Patinoire avec bandes',
      'Patinoire avec bandes pour enfants',
      'Patinoire de hockey',
      'Patinoire de patin libre',
      'Patinoire décorative',
      'Patinoire entretenue par les citoyens',
      'Patinoire extérieure',
      'Patinoire réfrigérée',
      'Petite patinoire de hockey',
      'Petite patinoire avec bandes',
      'Rond de glace',
      'Sentier de glace',
    ], allow_blank: true
  validates_inclusion_of :genre, in: [
      'C',
      'PP',
      'PPL',
      'PSE',
    ], allow_blank: true
  validates_inclusion_of :disambiguation, in: [
      'nord',
      'sud',
      'petite',
      'grande',
      'no 1',
      'no 2',
      'no 3',
      'réfrigérée',
    ], allow_blank: true
  validates_inclusion_of :source, in: [
      'donnees.ville.montreal.qc.ca',
      'ville.montreal.qc.ca',
      'ville.dorval.qc.ca',
      'docs.google.com',
    ]
  validates_inclusion_of :condition, in: %w(Excellente Bonne Mauvaise N/A), allow_blank: true
  validates_numericality_of :tel, only_integer: true, allow_blank: true
  validates_length_of :tel, is: 10, allow_blank: true

  before_validation :set_nom_and_description
  before_save :normalize

  scope :tracked, where(source: ['donnees.ville.montreal.qc.ca', 'ville.dorval.qc.ca'])
  scope :unaddressed, where(adresse: nil)
  scope :nongeocoded, where(lat: nil)
  scope :geocoded, where('lat IS NOT NULL')
  scope :ouvert, where(ouvert: true)

  def name
    "#{description}, #{parc} (#{genre})" # ignore disambiguation
  end

  def geocoded?
    lat.present? && lng.present? && lat.nonzero? && lng.nonzero?
  end

  def close?(a, b)
    (lat - a).abs < 0.002 && (lng - b).abs < 0.002
  end

private
  PREPOSITIONS = /\A(de la|de|des|du)\b/i

  def set_nom_and_description
    self.slug = parc.slug if parc

    self.description ||= if disambiguation == 'réfrigérée'
      'Patinoire réfrigérée'
    else
      case genre
      when 'C'
        'Patinoire entretenue par les citoyens'
      when 'PP'
        'Patinoire décorative'
      when 'PPL'
        'Patinoire de patin libre'
      when 'PSE'
        'Patinoire avec bandes'
      end
    end

    if %w(petite grande).include? disambiguation
      self.nom ||= "#{disambiguation.capitalize} #{description.downcase}, #{parc} (#{genre})"
    else
      extra = case disambiguation
      when 'réfrigérée', nil
        nil
      else
        " #{disambiguation}"
      end
      self.nom ||= "#{description}#{extra}, #{parc} (#{genre})"
    end
  end

  def normalize
    if parc && parc[PREPOSITIONS]
      parc[PREPOSITIONS] = parc[PREPOSITIONS].downcase
    end
  end
end
