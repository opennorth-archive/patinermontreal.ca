# coding: utf-8
class Patinoire < ActiveRecord::Base
  belongs_to :arrondissement

  validates_presence_of :nom, :description, :genre, :slug, :source, :arrondissement_id
  validates_uniqueness_of :nom, scope: :arrondissement_id
  validates_numericality_of :tel, only_integer: true, allow_blank: true
  validates_length_of :tel, is: 10, allow_blank: true

  validates_inclusion_of :description, in: [
    'Anneau de glace',
    'Aire de patinage libre',
    'Grande patinoire avec bandes',
    'Grande patinoire de hockey',
    'Patinoire avec bandes',
    'Patinoire avec bandes pour enfants',
    'Patinoire de hockey',
    'Patinoire sport d\'équipe',
    'Patinoire de patin libre',
    'Patinoire décorative',
    'Patinoire extérieure',
    'Patinoire naturelle',
    'Patinoire réfrigérée',
    'Petite patinoire avec bandes',
    'Petite patinoire de hockey',
    'Rond de glace',
    'Sentier de glace',
    'Sentier à patiner décoré',
    'Patinoire réfrigérée Bleu-Blanc-Bouge',
  ], allow_blank: true
  validates_inclusion_of :genre, in: [
    'PP',
    'PPL',
    'PSE',
  ], allow_blank: true
  validates_inclusion_of :disambiguation, in: [
    'no 1',
    'no 2',
    'no 3',
    'nord',
    'sud',
    'est',
    'ouest',
    'petite',
    'grande',
    'réfrigérée',
    'bbb-canadiens',
  ], allow_blank: true
  validates_inclusion_of :source, in: [
    'docs.google.com',
    'donnees.ville.montreal.qc.ca',
    'montreal-west.ca',
    'ville.dorval.qc.ca',
    'www.laval.ca',
    'www.ville.ddo.qc.ca',
    'www.longueuil.quebec',
    'www.boucherville.ca',
    'www.ville.brossard.qc.ca',
    'www.ville.laprairie.qc.ca',
    'candiac.ca',
  ]
  validates_inclusion_of :condition, in: %w(Excellente Bonne Mauvaise N/A), allow_blank: true

  before_validation :set_nom_and_description
  before_save :normalize

  scope :tracked, -> { where(source: ['donnees.ville.montreal.qc.ca', 'ville.dorval.qc.ca', 'www.longueuil.quebec']) }
  scope :geocoded, -> { where('lat IS NOT NULL') }
  scope :ouvert, -> { where(ouvert: true) }
  # Utility scopes for checking data quality.
  scope :unaddressed, -> { where(adresse: nil) }
  scope :nongeocoded, -> { where(lat: nil) }

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
    self.slug = if parc.present?
      parc.slug
    elsif description.present?
      description.slug
    else
      nom.slug
    end

    self.description ||= if disambiguation == 'réfrigérée'
      'Patinoire réfrigérée'
    else
      case genre
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
