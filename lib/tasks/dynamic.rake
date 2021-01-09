# coding: utf-8
namespace :import do
  desc 'Add rinks from donnees.ville.montreal.qc.ca'
  task montreal: :environment do
    disambiguation_lasalle = disambiguation_decelles = 1
    Nokogiri::XML(RestClient.get('http://www2.ville.montreal.qc.ca/services_citoyens/pdf_transfert/L29_PATINOIRE.xml')).css('patinoire').each do |node|
      # Add m-dash, except for Ahuntsic-Cartierville.
      nom_arr = node.at_css('nom_arr').text.
        sub('Ahuntsic - Cartierville', 'Ahuntsic-Cartierville').
        sub('Villeray-Saint-Michel - Parc-Extension', 'Villeray—Saint-Michel—Parc-Extension').
        sub('Côte-des-Neiges - Notre-Dame-de-Grâce', 'Côte-des-Neiges—Notre-Dame-de-Grâce').
        sub('L\'Île-Bizard - Sainte-Geneviève', "L'Île-Bizard—Sainte-Geneviève").
        gsub(' - ', '—')

      arrondissement = Arrondissement.find_or_initialize_by(nom_arr: nom_arr)
      arrondissement.cle = node.at_css('cle').text
      arrondissement.date_maj = Time.parse node.at_css('date_maj').text
      arrondissement.source = 'donnees.ville.montreal.qc.ca'

      begin
        arrondissement.save!

        # Expand/correct rink names to avoid later parsing errors
        xml_name = node.at_css('nom').text
          #.sub(' du parc ', ', parc ')
          #.gsub(/([a-z])\sparc/im, '\1, parc')
          .gsub(/bleu(.*)blanc(.*)bouge/im, 'Bleu-Blanc-Bouge')
          .strip
        xml_name = 'Patinoire Bleu-Blanc-Bouge, parc de Mésy (PSE)' if xml_name == 'Patinoire avec bandes, de Mésy (PSE)'
        xml_name = 'Patinoire Bleu-Blanc-Bouge, parc Le Carignan (PSE)' if xml_name == 'Patinoire réfrigérée,Bleu-Blanc-Bouge Le Carignan (PSE)'
        xml_name = 'Patinoire Bleu-Blanc-Bouge, parc François-Perrault (PSE)' if xml_name == 'Patinoire réfrigérée, Bleu-Blanc-Bouge F-Perrault (PSE)'
        xml_name = 'Patinoire Bleu-Blanc-Bouge, parc Hayward (PSE)' if xml_name == 'Patinoire ext avec bandes (BBB) , parc Hayward (PSE)'
#        xml_name = 'Patinoire décorative, C.E.C. René-Goupil (PP)' if xml_name == 'Centre comm R-Goupil, Patinoire décorative (PP)'
#        xml_name = 'Patinoire avec bandes, De Gaspé/Bernard (PSE)' if xml_name == 'Patinoire De Gaspé/Bernard (PSE)'  && arrondissement.cle == 'ahc'

        patinoire = Patinoire.find_or_initialize_by(nom: xml_name, arrondissement_id: arrondissement.id)
        %w(ouvert deblaye arrose resurface condition).each do |attribute|
          patinoire[attribute] = node.at_css(attribute).text
          patinoire[attribute] = (attribute == 'condition'? 'N/A' : false) if (patinoire[attribute].nil?)
        end

        description = case patinoire.nom
        when 'patinoire extérieure (PSE)', /Patinoire # \d\s?,(.*)/
          'Patinoire avec bandes'
        when /(.*)Bleu\-Blanc\-Bouge(.*)/
          'Patinoire réfrigérée Bleu-Blanc-Bouge'
        else
          patinoire.nom[/\A(.+?) ?(?:no [1-3]|nord|sud)?(?:,|-| du parc\b)/, 1] || patinoire.nom
        end

        patinoire.description = {
          'Anneau à patiner'           => 'Anneau de glace',
          'Carré de glace'             => 'Rond de glace',
          'Pat. avec bandes'           => 'Patinoire avec bandes',
          'Pati déco'                  => 'Patinoire décorative',
          'Patinoire Décorative'       => 'Patinoire décorative',
          'Sentiers Glacés'            => 'Sentier de glace',
          'Patinoire sans bandes'      => 'Patinoire extérieure',
          'Patinoire à bandes'         => 'Patinoire avec bandes',
          'Patnoire à bandes'          => 'Patinoire avec bandes',
          'Patinoire avec bande'       => 'Patinoire avec bandes',
          'Patinoire bandes'           => 'Patinoire avec bandes',
          'Patinoire ext. avec bandes' => 'Patinoire avec bandes',
          'Patinoire de hockey et patin libre' => 'Patinoire de patin libre',
        }.reduce(description) do |string,(from,to)|
          string.sub(/#{Regexp.escape from}\z/, to)
        end

        patinoire.genre = patinoire.nom[/\((PP|PPL|PSE)\)\z/, 1]

        patinoire.disambiguation = (patinoire.nom[/\A(Petite|Grande)\b/i, 1] || patinoire.nom[/[^-]\b(nord|sud|est|ouest|no \d)\b/i, 1]).andand.downcase
#        patinoire.disambiguation ||= "bbb-canadiens" if patinoire.nom[/(Bleu(\W)?Blanc(\W)?Bouge\b)|(\bBBB\b)\b/i, 1]
        patinoire.disambiguation ||= "no #{$1}" if patinoire.nom[/ (\d)\s?,/, 1]
        patinoire.disambiguation ||= 'réfrigérée' if patinoire.description == 'Patinoire réfrigérée' || patinoire.description == 'Patinoire réfrigérée Bleu-Blanc-Bouge'

        # Expand/correct park names.
        parc = patinoire.nom[/, ([^(]+?)(?: no \d)? \(/, 1] || patinoire.nom[/ du parc (.+) \(/, 1] || patinoire.nom[/(.+) \(/, 1]
        patinoire.parc = {
          'C-de-la-Rousselière'              => 'Clémentine-De La Rousselière',
          'Cité-Jardin'                      => 'de la Cité Jardin',
          'Confédération'                    => 'de la Confédération',
          'de la Rive-Boisé'                 => 'de la Rive-Boisée',
          'Decelle'                          => 'Decelles',
          'Duff court'                       => 'Duff Court',
          'étang Jarry'                      => 'Jarry',
          'Ignace-Bourget-anneau de vitesse' => 'Ignace-Bourget',
          'lalancette'                       => 'Lalancette',
          'Lac aux Castors ,'                => 'Lac aux Castors',
          'Marc-Aurèle-Fortin'               => 'Hans-Selye',
          'Merci'                            => 'de la Merci',
          'Patinoire bandes Pierre-Bédard'   => 'Pierre-Bédard',
          'Saint-Aloysis'                    => 'Saint-Aloysius',
          'Sainte-Maria-Goretti'             => 'Maria-Goretti',
          'Y-Thériault/Sherbrooke'           => 'Yves-Thériault/Sherbrooke',
          'Roger Rousseau'                   => 'Roger-Rousseau',
          'De Gaspé/Bernard'                 => 'Champ des possibles',
          # Need to do independent research to find where these are.
          'patinoire extérieure'             => ''
        }.reduce(parc.strip) do |string,(from,to)|
          string.sub(/#{Regexp.escape from}\z/, to)
        end
        patinoire.parc.slice!(/\AParc /i)

        # Remove disambiguation from description.
        patinoire.description.slice!(/ (\d|Nord|Sud|Est|Ouest)\z/)

        # There is no "no 2".
        # if patinoire.nom == 'Patinoire de patin libre, Le Prévost no 1 (PPL)'
        #   patinoire.parc = 'Le Prévost'
        #   patinoire.disambiguation = nil
        # end

        # There is no "no 2", also require a valid description
        if ['Patinoire # 1, Parc Jonathan-Wilson (PSE)', 'Patinoire # 1, Parc Joseph-Avila-Proulx (PSE)', 'Patinoire # 1, Parc Robert-Sauvé (PSE)'].include? patinoire.nom
          patinoire.disambiguation = nil
        end

        # Require a valid description
        # if ['Patinoire # 2 , Parc Eugène-Dostie (PSE)', 'Patinoire # 1 , Parc Eugène-Dostie (PSE)'].include? patinoire.nom
        #   patinoire.description = 'Patinoire de hockey'
        #   patinoire.disambiguation = "no #{flip}"
        #   flip = flip == 1 ? 2 : 1
        # end

        # There are identical lines.
        if patinoire.parc == 'LaSalle' && patinoire.genre == 'PSE'
         patinoire.disambiguation = "no #{disambiguation_lasalle}"
         disambiguation_lasalle = disambiguation_lasalle == 1 ? 2 : 1
        end

        # There are identical lines.
        if patinoire.parc == 'Decelles' && patinoire.genre == 'PSE'
         patinoire.disambiguation = "no #{disambiguation_decelles}"
         disambiguation_decelles = disambiguation_decelles == 1 ? 2 : 1
        end

        # There are identical lines, with identical names
        # if patinoire.parc == 'de Mésy' && patinoire.genre == 'PSE'
        #   patinoire.nom = "Patinoire avec bandes no #{flip}, de Mésy (PSE)"
        #   patinoire.disambiguation = "no #{flip}"
        #   flip = flip == 1 ? 2 : 1
        # end

        patinoire.source = 'donnees.ville.montreal.qc.ca'
        begin
          patinoire.save!
        rescue => e
          puts "#{e.inspect}: #{patinoire.inspect}"
        end
      rescue => e
        puts "#{e.inspect}: #{arrondissement.inspect}"
      end
    end
  end

  # desc 'Add rinks from www.longueuil.quebec'
  task longueuil: :environment do
    json = JSON.parse(RestClient.get('https://cms.longueuil.quebec/fr/api/paragraph/accordion_item/c8b8abef-6a93-4389-8caf-ec7c41f2861c'))
    html = Nokogiri::HTML(json['data']['attributes']['content']['processed'])

    # First table: Vieux-Longueuil conditions

    arrondissement = Arrondissement.find_or_initialize_by(nom_arr: 'Vieux-Longueuil')
    arrondissement.source = 'www.longueuil.quebec'
    arrondissement.date_maj = Time.now
    arrondissement.save!

    html.css('table')[0].css('tr:gt(1)').each do |tr|
      nb_rinks = [tr.css('td:eq(2) p').count, 1].max
      nb_rinks.times do |i|
        attributes = import_html_table_row tr, i + 1

        # Expand/correct park names
        attributes[:parc] = "Michel-Chartrand" if (attributes[:parc] == "Michel Chartrand")
        attributes[:parc] = "Catherine-Primot" if (attributes[:parc] == "Catherine-Primot (anciennement Saint-Charles)")
        if attributes[:parc] == "Lionel-Groulx / Bleu Blanc Bouge"
          attributes[:parc] = "Lionel-Groulx"
          attributes[:description] = 'Patinoire réfrigérée Bleu-Blanc-Bouge'
        end

        patinoire = Patinoire.find_or_initialize_by(parc: attributes[:parc], genre: attributes[:genre], arrondissement_id: arrondissement.id)
        patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
        begin
         patinoire.save!
        rescue => e
         puts "#{e.inspect}: #{patinoire.inspect}"
        end
      end
    end

    # Second table: Saint-Hubert conditions

    arrondissement = Arrondissement.find_or_initialize_by(nom_arr: 'Saint-Hubert')
    arrondissement.source = 'www.longueuil.quebec'
    arrondissement.date_maj = Time.now
    arrondissement.save!

    html.css('table')[1].css('tr:gt(1)').each do |tr|
      nb_rinks = [tr.css('td:eq(2) p').count, 1].max
      nb_rinks.times do |i|
        attributes = import_html_table_row tr, i + 1
        patinoire = Patinoire.find_or_initialize_by(parc: attributes[:parc], genre: attributes[:genre], arrondissement_id: arrondissement.id)
        patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
        begin
         patinoire.save!
        rescue => e
         puts "#{e.inspect}: #{patinoire.inspect}"
        end
      end
    end
  end

  def import_html_table_row(tr, offset = 1)
    nom = get_td_merged_line(tr.css('td:eq(2)'), offset)
    passable = get_td_merged_line(tr.css("td:eq(4)"), offset).downcase().include?('x')
    ouvert = passable || get_td_merged_line(tr.css("td:eq(3)"), offset).downcase().include?('x')

    attributes = {
      parc: tr.css('td:eq(1)').text.gsub(/[[:space:]]/, ' ').sub('Parc ', '').strip,
      genre:
      case nom
      when 'Rond de glace', 'Rond de glace'
        'PPL'
      when 'Patinoire', 'Patinoire permanente', 'Patinoire réfrigérée'
        'PSE'
      else
        puts "Unknown rink '#{nom}'"
        nil
      end ,
      ouvert: ouvert,
      condition: case
      when passable
        'Bonne'
      when ouvert
        'Excellente'
      else
        'N/A'
      end
    }

    return attributes
  end

  def get_td_merged_line(td, offset)
    content = td.css("p:eq(#{offset})").text.strip
    content = td.text.strip if content.blank? && offset == 1
    return content
  end

  task laval: :environment do
    doc = Nokogiri::HTML(URI.open("https://www.laval.ca/Pages/Fr/Activites/patinoires-exterieures.aspx#QuartierNormalc27b7053ad9648ccb5fa4897a6c80800"))
    json = JSON.parse(doc.xpath('//script[not(@src)]').map{ |js| js.text[/filteredSportFacilitiesConditionsJson_QuartierNormalc27b7053ad9648ccb5fa4897a6c80800\s?=\s?(.*);/,1] }.compact.first)

    pattern_parc = /patinoire extérieure - ((.*au )?parc(-école)?\s?)?/i
    pattern_pse = /hockey(.*)patinoire/i
    pattern_pp = /patinage(.*)sentier/i
    pattern_ppl = /patinage(.*)patinoire/i

    json.each { |rink|
      attributes = {
        parc: rink['SportsFacilitiesLocation']['Label'].gsub(pattern_parc, ''),
        ouvert: rink['SportsFacilitiesStatus']['Label'] == "Ouvert",
        condition: 'N/A',
        genre: case
        when (rink['SportsFacilitiesActivity']['Label'].match(pattern_pse))
          'PSE'
        when (rink['SportsFacilitiesActivity']['Label'].match(pattern_pp))
          'PP'
        when (rink['SportsFacilitiesActivity']['Label'].match(pattern_ppl))
          'PPL'
        else
          nil
        end
      }

      patinoire = Patinoire.find_by(parc: attributes[:parc], genre: attributes[:genre], source: "www.laval.ca")
      next if patinoire == nil

      patinoire.attributes = attributes

      begin
       patinoire.save!
      rescue => e
       puts "#{e.inspect}: #{patinoire.inspect}"
      end
    }

    begin
     Arrondissement.where(source: "www.laval.ca").update_all(date_maj: Time.now)
    rescue => e
     puts "Could not update Arrondissement.date_maj: #{e.inspect}"
    end
  end
end
