# coding: utf-8

# The totals on the Sherlock page are incorrect.
#  16 Ahuntsic-Cartierville (16 as in XML)
#   7 Anjou
#  22 Côte-des-Neiges—Notre-Dame-de-Grâce (22 as in XML)
#  29 Dollard-des-Ormeaux has 29, including PP
#   8 L'Île-Bizard–Sainte-Geneviève has 8, not 9
#   8 LaSalle
#  12 Lachine
#  14 Le Plateau-Mont-Royal has 12, not 11 (14 in XML)
#  14 Le Sud-Ouest (13 in XML: no PPL at de la Vérendrye)
#  21 Mercier—Hochelaga-Maisonneuve (21 as in XML)
#   6 Montréal-Nord
#   3 Montréal-Ouest
#  10 Outremont
#  14 Pierrefonds-Roxboro has 14, not 25
#  18 Rivière-des-Prairies—Pointe-aux-Trembles (18 as in XML)
#  18 Rosemont–La Petite-Patrie has 18, including C (17 in XML: no C)
#  27 Saint-Laurent has 24, including rond de glace (2 from joseeboudreau@ville.montreal.qc.ca)
#   8 Saint-Léonard
#  12 Verdun
#   6 Ville-Marie (5 in XML: no Bassin Bonsecours)
#  17 Villeray–Saint-Michel–Parc-Extension has 16, not 15 (15 in XML: no Sainte-Yvette, no PSE at Nicolas-Tillemont, but has PSE at Perrault)
# 290 rinks total
namespace :import do
  desc 'Add rinks from donnees.ville.montreal.qc.ca'
  task :xml => :environment do
    Nokogiri::XML(RestClient.get('http://depot.ville.montreal.qc.ca/patinoires/data.xml')).css('patinoire').each do |node|
      # Add m-dash, except for Ahuntsic-Cartierville.
      nom_arr = node.at_css('nom_arr').text.sub('Ahuntsic - Cartierville', 'Ahuntsic-Cartierville').gsub(' - ', '—')

      arrondissement = Arrondissement.find_or_initialize_by_nom_arr nom_arr
      arrondissement.cle = node.at_css('cle').text
      arrondissement.date_maj = Time.parse node.at_css('date_maj').text
      arrondissement.save!

      patinoire = Patinoire.find_or_initialize_by_nom_and_arrondissement_id node.at_css('nom').text, arrondissement.id
      %w(ouvert deblaye arrose resurface condition).each do |attribute|
        patinoire[attribute] = node.at_css(attribute).text
      end
      patinoire.description = patinoire.nom[/\A(.+?) ?(?:no [1-3]|nord|sud)?,/, 1]
      patinoire.genre = patinoire.nom[/\((PP|PPL|PSE)\)\z/, 1]
      patinoire.disambiguation = patinoire.nom[/\b(nord|sud|\APetite|\AGrande|no \d)\b/i, 1].andand.downcase
      # Help disambiguate rinks imported from Sherlock.
      patinoire.disambiguation = 'réfrigérée' if patinoire.description == 'Patinoire réfrigérée'
      # Expand/correct park names.
      patinoire.parc = {
        'Beauséjour'             => 'de Beauséjour',
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
      }.reduce(patinoire.nom[/, ([^(]+) \(/, 1]) do |string,(from,to)|
        string.sub(from, to)
      end

      # "Aire de patinage libre" with "PSE" is nonsense.
      if patinoire.nom == 'Aire de patinage libre, Kent (sud) (PSE)'
        patinoire.genre = 'PPL'
      end
      # There is no "no 2".
      if patinoire.nom == 'Patinoire de patin libre no 1, Le Prévost (PPL)'
        patinoire.disambiguation = nil
      end
      patinoire.save!
    end
  end

  desc 'Add rinks from ville.dorval.qc.ca'
  task :dorval => :environment do
    arrondissement = Arrondissement.find_or_create_by_nom_arr 'Dorval'

    Nokogiri::HTML(RestClient.get('http://www.ville.dorval.qc.ca/loisirs/fr/default.asp?contentID=808')).css('tr:gt(2)').each do |tr|
      condition = 'N/A'
      { 4 => 'Excellente',
        5 => 'Bonne',
        6 => 'Mauvaise',
      }.each do |i,v|
        if tr.at_css("td:eq(#{i})").text.gsub(/[[:space:]]/, '').present?
          condition = v
        end
      end

      text = tr.at_css('td:eq(1)').text
      attributes = {
        genre: text['Patinoire récréative et de hockey'] ? 'PSE' : 'PPL',
        parc: tr.at_css('strong').text.sub(/\AParc /, ''),
        adresse: tr.at_css('p').children[1].text,
        tel: text[/\(514\) \d{3}-\d{4}/].delete('^0-9'),
        ouvert: tr.at_css('td:eq(2)').text.gsub(/[[:space:]]/, '').present?,
        condition: condition,
      }

      # http://www.ville.dorval.qc.ca/loisirs/fr/googlemap_arenas.html
      # @todo remove once geocoding spreadsheet done
      coordinates = {
        'Surrey' => '45.453809,-73.772700',
        'Courtland' => '45.444130,-73.767014',
        'St-Charles' => '45.438047,-73.729033',
      }[attributes[:parc]]
      if coordinates
        attributes[:lat], attributes[:lng] = coordinates.split(',').map(&:to_f)
      end

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id attributes[:parc], attributes[:genre], arrondissement.id
      patinoire.attributes = attributes
      patinoire.save!

      if text['Patinoire récréative et de hockey']
        patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id attributes[:parc], 'PPL', arrondissement.id
        patinoire.attributes = attributes.merge(genre: 'PPL')
        patinoire.save!
      end
    end
  end
end