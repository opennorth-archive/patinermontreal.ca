class Patinoire < ActiveRecord::Base
  belongs_to :arrondissement

  validates_presence_of :nom, :parc, :arrondissement_id
  validates_presence_of :description, :genre, if: :condition? # if from XML
  validates_uniqueness_of :nom
  validates_inclusion_of :description, in: [
      'Aire de patinage libre',
      'Grande patinoire avec bandes',
      'Patinoire avec bandes',
      'Patinoire de patin libre',
      'Patinoire décorative',
      'Patinoire réfrigérée',
      'Petite patinoire avec bandes',
    ], allow_blank: true
  validates_inclusion_of :genre, in: %w(PP PPL PSE), allow_blank: true
  validates_inclusion_of :condition, in: %w(Excellente Bonne Mauvaise N/A), allow_blank: true

  before_validation :set_description_and_genre

private

  def set_description_and_genre
    if nom
      self.description = nom[/\A(.+?) ?(?:no [1-3]|nord|sud)?,/, 1]
      self.genre = nom[/\((PP|PPL|PSE)\)\z/, 1]
      self.parc = {
        'C-de-la-Rousselière'    => 'Clémentine-De La Rousselière',
        'Cité-Jardin'            => 'de la Cité Jardin',
        'De la Petite-Italie'    => 'Petite Italie',
        'Kent'                   => 'de Kent',
        'Lac aux Castors'        => 'du Mont-Royal',
        'Lac des castors'        => 'du Mont-Royal',
        'Marc-Aurèle-Fortin'     => 'Hans-Selye',
        'Saint-Aloysis'          => 'Saint-Aloysius',
        'Sainte-Maria-Goretti'   => 'Maria-Goretti',
        'Y-Thériault/Sherbrooke' => 'Yves-Thériault/Sherbrooke',
        # case-sensitive
        /^de la\b/i => 'de la',
        /^de\b/i    => 'de',
        /^des\b/i   => 'des',
        /^du\b/i    => 'du',
      }.reduce(nom[/, ([^(]+) \(/, 1]) do |acc,(from,to)|
        acc.sub(from, to)
      end
    end
    true
  end
end
