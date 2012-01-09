# coding: utf-8
namespace :import do
  desc 'Add rinks from donnees.ville.montreal.qc.ca'
  task :donnees => :environment do
    flip = 1
    Nokogiri::XML(RestClient.get('http://depot.ville.montreal.qc.ca/patinoires/data.xml')).css('patinoire').each do |node|
      # Add m-dash, except for Ahuntsic-Cartierville.
      nom_arr = node.at_css('nom_arr').text.sub('Ahuntsic - Cartierville', 'Ahuntsic-Cartierville').gsub(' - ', '—')

      arrondissement = Arrondissement.find_or_initialize_by_nom_arr nom_arr
      arrondissement.cle = node.at_css('cle').text
      arrondissement.date_maj = Time.parse node.at_css('date_maj').text
      arrondissement.source = 'donnees.ville.montreal.qc.ca'
      arrondissement.save!

      patinoire = Patinoire.find_or_initialize_by_nom_and_arrondissement_id node.at_css('nom').text, arrondissement.id
      %w(ouvert deblaye arrose resurface condition).each do |attribute|
        patinoire[attribute] = node.at_css(attribute).text
      end
      patinoire.description = patinoire.nom[/\A(.+?) ?(?:no [1-3]|nord|sud)?[,-]/, 1].sub('Pat. avec bandes', 'Patinoire avec bandes')
      patinoire.genre = patinoire.nom[/\((PP|PPL|PSE)\)\z/, 1]
      patinoire.disambiguation = patinoire.nom[/\b(nord|sud|\APetite|\AGrande|no \d)\b/i, 1].andand.downcase
      # Help disambiguate rinks imported from Sherlock.
      patinoire.disambiguation = 'réfrigérée' if patinoire.description == 'Patinoire réfrigérée'
      # Expand/correct park names.
      patinoire.parc = {
        'C-de-la-Rousselière'    => 'Clémentine-De La Rousselière',
        'Cité-Jardin'            => 'de la Cité Jardin',
        'De la Petite-Italie'    => 'Petite Italie',
        'Duff court'             => 'Duff Court',
        'Lac aux Castors'        => 'du Mont-Royal',
        'Lac des castors'        => 'du Mont-Royal',
        'Marc-Aurèle-Fortin'     => 'Hans-Selye',
        'Saint-Aloysis'          => 'Saint-Aloysius',
        'Sainte-Maria-Goretti'   => 'Maria-Goretti',
        'Y-Thériault/Sherbrooke' => 'Yves-Thériault/Sherbrooke',
      }.reduce(patinoire.nom[/, ([^(]+?)(?: no \d)? \(/, 1]) do |string,(from,to)|
        string.sub(from, to)
      end
      patinoire.parc.slice!(/\AParc /i)

      # "Aire de patinage libre" with "PSE" is nonsense.
      if patinoire.nom == 'Aire de patinage libre, Kent (sud) (PSE)'
        patinoire.genre = 'PPL'
      end
      # There is no "no 2".
      if patinoire.nom == 'Patinoire de patin libre, Le Prévost no 1 (PPL)'
        patinoire.parc = 'Le Prévost'
        patinoire.disambiguation = nil
      end
      # There are identical lines.
      if patinoire.parc == 'LaSalle' && patinoire.genre == 'PSE'
        patinoire.disambiguation = "no #{flip}"
        flip = flip == 1 ? 2 : 1
      end
      patinoire.source = 'donnees.ville.montreal.qc.ca'
      begin
        patinoire.save!
      rescue => e
        puts "#{e.inspect}: #{patinoire.inspect}"
      end
    end
  end

  desc 'Add rinks from ville.dorval.qc.ca'
  task :dorval => :environment do
    arrondissement = Arrondissement.find_or_initialize_by_nom_arr 'Dorval'
    arrondissement.source = 'ville.dorval.qc.ca'
    arrondissement.date_maj = Time.now
    arrondissement.save!

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
        source: 'ville.dorval.qc.ca',
      }

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id attributes[:parc], attributes[:genre], arrondissement.id

      unless patinoire.geocoded?
        # http://www.ville.dorval.qc.ca/loisirs/fr/googlemap_arenas.html
        # http://www.ville.dorval.qc.ca/loisirs/fr/googlemap_parcs.html
        coordinates = {
          'Courtland' => '45.444130,-73.767014',
          'St-Charles' => '45.438047,-73.729033',
          'Surrey' => '45.453809,-73.772700',
          'Windsor' => '45.440757,-73.748860',
        }[attributes[:parc]]
        if coordinates
          attributes[:lat], attributes[:lng] = coordinates.split(',').map(&:to_f)
        end
      end

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