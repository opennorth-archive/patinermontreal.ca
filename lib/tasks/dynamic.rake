# coding: utf-8
namespace :import do
  desc 'Add rinks from donnees.ville.montreal.qc.ca'
  task montreal: :environment do
    flip = 1
    Nokogiri::XML(RestClient.get('http://www2.ville.montreal.qc.ca/services_citoyens/pdf_transfert/L29_PATINOIRE.xml')).css('patinoire').each do |node|
      # Add m-dash, except for Ahuntsic-Cartierville.
      nom_arr = node.at_css('nom_arr').text.
        sub('Ahuntsic - Cartierville', 'Ahuntsic-Cartierville').
        sub('Villeray-Saint-Michel - Parc-Extension', 'Villeray—Saint-Michel—Parc-Extension').
        sub('Côte-des-Neiges - Notre-Dame-de-Grâce', 'Côte-des-Neiges—Notre-Dame-de-Grâce').
        sub('L\'Île-Bizard - Sainte-Geneviève', "L'Île-Bizard—Sainte-Geneviève").
        gsub(' - ', '—')

      arrondissement = Arrondissement.find_or_initialize_by_nom_arr(nom_arr)
      arrondissement.cle = node.at_css('cle').text
      arrondissement.date_maj = Time.parse node.at_css('date_maj').text
      arrondissement.source = 'donnees.ville.montreal.qc.ca'

      begin
        arrondissement.save!

        # Expand/correct rink names to avoid later parsing errors
        xml_name = node.at_css('nom').text.sub(' du parc ', ', parc ').gsub(/([a-z])\sparc/im, '\1, parc').gsub(/bleu(.*)blanc(.*)bouge/im, 'Bleu-Blanc-Bouge').strip
        xml_name = 'Patinoire Bleu-Blanc-Bouge, Parc Confédération (PSE)' if xml_name == 'Patinoire Bleu-Blanc-Bouge (PSE)' && arrondissement.cle == 'cdn' 
        xml_name = 'Patinoire Bleu-Blanc-Bouge, Parc de Mésy (PSE)' if xml_name == 'Patinoire avec bandes, de Mésy (PSE)' && arrondissement.cle == 'ahc' 
        xml_name = 'Patinoire réfrigérée Bleu-Blanc-Bouge, Parc François-Perrault (PSE)' if xml_name == 'Patinoire réfrigérée Bleu-Blanc-Bouge (PSE)' && arrondissement.cle == 'vsp'
        xml_name = 'Patinoire avec bandes, Parc Jeanne-Lapierre (PSE)' if xml_name == 'Patinoire avec bandes, Parc Jean-Lapierre (PSE)' && arrondissement.cle == 'rdp'
        xml_name = 'Patinoire de patin libre, parc du Glacis (PP)' if xml_name == 'Patinoire du Glacis (PP)'
        xml_name = 'Patinoire décorative, Toussaint-Louverture (PP)' if xml_name == 'Patinoire décorative Toussaint-Louverture (PP)'
        xml_name = 'Patinoire extérieure, Domaine Chartier (PPL)' if xml_name == 'Patinoire extérieure Domaine Chartier (PPL)'
#         xml_name = 'Patinoire décorative, C.E.C. René-Goupil (PP)' if xml_name == 'Centre comm R-Goupil, Patinoire décorative (PP)'
        xml_name = 'Patinoire avec bandes, De Gaspé/Bernard (PSE)' if xml_name == 'Patinoire De Gaspé/Bernard (PSE)'
        xml_name = 'Patinoire décorative, parc Aimé-Léonard (PP)' if xml_name == 'Patinoire, parc Aimé-Léonard (PP)'
        xml_name = 'Patinoire de patin libre, parc Hans-Selye (PPL)' if xml_name == 'Patinoire de patin libre,parc Hans-Selye (PPL)'

        patinoire = Patinoire.find_or_initialize_by_nom_and_arrondissement_id(xml_name, arrondissement.id)
        %w(ouvert deblaye arrose resurface condition).each do |attribute|
          patinoire[attribute] = node.at_css(attribute).text
          patinoire[attribute] = (attribute == 'condition'? 'N/A' : false) if (patinoire[attribute].nil?)
        end

        description = case patinoire.nom
        when 'Patinoire bandes Pierre-Bédard (PSE)', 'patinoire extérieure (PSE)'
          'Patinoire avec bandes'
        when /(.*)Bleu\-Blanc\-Bouge(.*)/
          'Patinoire réfrigérée Bleu-Blanc-Bouge'
        when 'Patinoire de parin libre, parc Sauvé (PPL)'
          'Patinoire de patin libre'
        else
          patinoire.nom[/\A(.+?) ?(?:no [1-3]|nord|sud)?(?:,|-| du parc\b)/, 1] || patinoire.nom
        end

        patinoire.description = {
          'Anneau à patiner'           => 'Anneau de glace',
          'Pat. avec bandes'           => 'Patinoire avec bandes',
          'Pati déco'                  => 'Patinoire décorative',
          'Patinoire Décorative'       => 'Patinoire décorative',
          'Sentiers Glacés'            => 'Sentier de glace',
          'Patinoire de hockey et patin libre' => 'Patinoire de patin libre',
          'Patinoire à bandes'         => 'Patinoire avec bandes',
          'Patnoire à bandes'          => 'Patinoire avec bandes',
          'Patinoire avec bande'       => 'Patinoire avec bandes',
          'Patinoire bandes'           => 'Patinoire avec bandes',
          'Patinoire ext. avec bandes' => 'Patinoire avec bandes',
        }.reduce(description) do |string,(from,to)|
          string.sub(/#{Regexp.escape from}\z/, to)
        end

        patinoire.genre = patinoire.nom[/\((PP|PPL|PSE)\)\z/, 1]

        patinoire.disambiguation = (patinoire.nom[/\A(Petite|Grande)\b/i, 1] || patinoire.nom[/[^-]\b(nord|sud|est|ouest|no \d)\b/i, 1]).andand.downcase
#        patinoire.disambiguation ||= "bbb-canadiens" if patinoire.nom[/(Bleu(\W)?Blanc(\W)?Bouge\b)|(\bBBB\b)\b/i, 1]
        patinoire.disambiguation ||= "no #{$1}" if patinoire.nom[/ (\d),/, 1]
        patinoire.disambiguation ||= 'réfrigérée' if patinoire.description == 'Patinoire réfrigérée' || patinoire.description == 'Patinoire réfrigérée Bleu-Blanc-Bouge'

        # Expand/correct park names.
        parc = patinoire.nom[/, ([^(]+?)(?: no \d)? \(/, 1] || patinoire.nom[/ du parc (.+) \(/, 1] || patinoire.nom[/(.+) \(/, 1]
        patinoire.parc = {
          'C-de-la-Rousselière'              => 'Clémentine-De La Rousselière',
          'Cité-Jardin'                      => 'de la Cité Jardin',
          'Confédération'                    => 'de la Confédération',
          'de la Rive-Boisé'                 => 'de la Rive-Boisée',
          'De la Petite-Italie'              => 'Petite Italie',
          'Des Hirondelles'                  => 'des Hirondelles',
          'Decelle'                          => 'Decelles',
          'Duff court'                       => 'Duff Court',
          'Ignace-Bourget-anneau de vitesse' => 'Ignace-Bourget',
          'lalancette'                       => 'Lalancette',
          'Lac aux castors'                  => 'Lac aux Castors',
          'Lac des castors'                  => 'Lac aux Castors',
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
        }.reduce(parc) do |string,(from,to)|
          string.sub(/#{Regexp.escape from}\z/, to)
        end
        patinoire.parc.slice!(/\AParc /i)

        # Remove disambiguation from description.
        patinoire.description.slice!(/ (\d|Nord|Sud|Est|Ouest)\z/)

        # "Aire de patinage libre" with "PSE" is nonsense.
        if patinoire.nom == 'Aire de patinage libre, Kent (sud) (PSE)'
          patinoire.genre = 'PPL'
        end

        # There is no "no 2".
        if patinoire.nom == 'Patinoire de patin libre, Le Prévost no 1 (PPL)'
          patinoire.parc = 'Le Prévost'
          patinoire.disambiguation = nil
        end
        
        # There is no "no 2", also require a valid description
        if ['Patinoire # 1, Parc Jonathan-Wilson (PSE)', 'Patinoire # 1, Parc Joseph-Avila-Proulx (PSE)', 'Patinoire # 1, Parc Robert-Sauvé (PSE)'].include? patinoire.nom
          patinoire.disambiguation = nil
          patinoire.description = 'Patinoire de hockey'
        end
        
        # Require a valid description
        if ['Patinoire # 2 , Parc Eugène-Dostie (PSE)', 'Patinoire # 1 , Parc Eugène-Dostie (PSE)'].include? patinoire.nom
          patinoire.description = 'Patinoire de hockey'
          patinoire.disambiguation = "no #{flip}"
          flip = flip == 1 ? 2 : 1
        end

        # There are identical lines.
        if patinoire.parc == 'LaSalle' && patinoire.genre == 'PSE'
          patinoire.disambiguation = "no #{flip}"
          flip = flip == 1 ? 2 : 1
        end

        # There are identical lines.
        if patinoire.parc == 'Decelles' && patinoire.genre == 'PSE'
          patinoire.disambiguation = "no #{flip}"
          flip = flip == 1 ? 2 : 1
        end

        # There are identical lines, with identical names
#         if patinoire.parc == 'de Mésy' && patinoire.genre == 'PSE'
#           patinoire.nom = "Patinoire avec bandes no #{flip}, de Mésy (PSE)"
#           patinoire.disambiguation = "no #{flip}"
#           flip = flip == 1 ? 2 : 1
#         end
        
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
    doc = Nokogiri::HTML(RestClient.get('https://www.longueuil.quebec/fr/conditions-sites-hivernaux'))
    
    # Vieux-Longueuil conditions
    
    arrondissement = Arrondissement.find_or_initialize_by_nom_arr('Vieux-Longueuil')
    arrondissement.source = 'www.longueuil.quebec'
    arrondissement.date_maj = Time.now
    arrondissement.save!
   
    # First table: Sentiers de ski de fond et pentes à glisser  
    tr = doc.css(".field-name-body table")[0].css("tr:eq(7)")
    attributes = { 
      parc: 'Michel-Chartrand',
      genre: 'PPL',
      ouvert: tr.css("td:eq(4)").text.downcase().include?('x') ,
      resurface: tr.css("td:eq(2)").text.downcase().include?('x') ,
      condition: 'N/A'
    }

    attributes[:condition] = 'Excellente' if tr.css("td:eq(4)").text.downcase().include?('x')
    attributes[:condition] = 'Bonne' if tr.css("td:eq(5)").text.downcase().include?('x')
    
    # Fix for "passable" but not "open"
    attributes[:ouvert] = true if attributes[:condition] == 'Bonne'
    
    patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], attributes[:genre], arrondissement.id)
    patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
    begin
      patinoire.save!
    rescue => e
      puts "#{e.inspect}: #{patinoire.inspect}"
    end

    # Second table: Patinoire réfrigérée BBB
    tr = doc.css(".field-name-body table")[1].css("tr:eq(3)")
    attributes = import_html_table_row tr, nil
    attributes[:parc] = 'Lionel-Groulx'

    patinoire = Patinoire.find_or_initialize_by_description_and_parc_and_arrondissement_id('Patinoire réfrigérée Bleu-Blanc-Bouge', attributes[:parc], arrondissement.id)
    patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
    begin
      patinoire.save!
    rescue => e
      puts "#{e.inspect}: #{patinoire.inspect}"
    end
   
    # Third table: Patinoires et surfaces glacées 
    previous = ''
    doc.css('.field-name-body table')[2].css('tr:gt(2)').each do |tr|
      attributes = import_html_table_row tr, previous
      previous = attributes[:parc]

      # Expand/correct park names
      attributes[:parc] = "des Sureaux" if (attributes[:parc] == "Des Sureaux")
      attributes[:parc] = "de Normandie" if (attributes[:parc] == "Normandie (de)")

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], attributes[:genre], arrondissement.id)
      patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
      begin
        patinoire.save!
      rescue => e
        puts "#{e.inspect}: #{patinoire.inspect}"
      end
    end
        
    # Saint-Hubert conditions
    
    arrondissement = Arrondissement.find_or_initialize_by_nom_arr('Saint-Hubert')
    arrondissement.source = 'www.longueuil.quebec'
    arrondissement.date_maj = Time.now 
    arrondissement.save!
   
    # First table: Sentiers de ski de fond et pentes à glisser  
    tr = doc.css(".field-name-body table")[3].css("tr:gt(6)").each do |tr|
      spanned = tr.css('> td').count == 6 
      offset = spanned ? -1 : 0
      attributes = { 
        parc: 'de la Cité',
        ouvert: tr.css("td:eq(#{5+offset})").text.downcase().include?('x') ,
        resurface: tr.css("td:eq(#{3+offset})").text.downcase().include?('x') ,
        condition: 'N/A'
      }
      attributes[:genre] = 'PPL' if tr.css("td:eq(#{2+offset})").text == 'Pavillon'
      attributes[:genre] = 'PP' if tr.css("td:eq(#{2+offset})").text == 'Raquette'
      
      attributes[:condition] = 'Excellente' if tr.css("td:eq(#{5+offset})").text.downcase().include?('x')
      attributes[:condition] = 'Bonne' if tr.css("td:eq(#{6+offset})").text.downcase().include?('x')

      # Fix for "passable" but not "open"
      attributes[:ouvert] = true if attributes[:condition] == 'Bonne'
      
      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], attributes[:genre], arrondissement.id)
      patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
      begin
        patinoire.save!
      rescue => e
        puts "#{e.inspect}: #{patinoire.inspect}"
      end
    end

    # Second table: Patinoires et surfaces glacées 
    previous = ''
    doc.css(".field-name-body table")[4].css("tr:gt(2)").each do |tr|
      attributes = import_html_table_row tr, previous
      previous = attributes[:parc]

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], attributes[:genre], arrondissement.id)
      patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
      begin
        patinoire.save!
      rescue => e
        puts "#{e.inspect}: #{patinoire.inspect}"
      end
    end
    
    # Greenfield Park conditions
    
    arrondissement = Arrondissement.find_or_initialize_by_nom_arr('Greenfield Park')
    arrondissement.source = 'www.longueuil.quebec'
    arrondissement.date_maj = Time.now 
    arrondissement.save!
   
    # Second table: Patinoires et surfaces glacées 
    previous = ''
    doc.css(".field-name-body table")[5].css("tr:gt(2)").each do |tr|
      attributes = import_html_table_row tr, previous
      previous = attributes[:parc]

      # Expand/correct park names
      attributes[:parc] = "Jubilée" if (attributes[:parc] == "Jubilee")

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], attributes[:genre], arrondissement.id)
      patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
      begin
        patinoire.save!
      rescue => e
        puts "#{e.inspect}: #{patinoire.inspect}"
      end
    end
  end
  
  def import_html_table_row(tr, previous_parc)
    spanned = tr.css('> td').count == 4 
    offset = spanned ? -1 : 0
    nom = tr.css("td:eq(#{2+offset})").text.gsub(/[[:space:]]/, ' ').strip
    attributes = { 
      parc: spanned ? previous_parc : tr.at_css('td').text.gsub(/[[:space:]]/, ' ').sub('Parc ', '').strip ,
      genre: case nom
      when 'Surface glacée'
        'PPL'
      when 'Patinoire', 'Patinoire permanente'
        'PSE'
      else  
        puts "Unknown rink '#{nom}'"
        nil 
      end ,
      ouvert: tr.css("td:eq(#{3+offset})").text.downcase().include?('x') ,
      condition: 'N/A'
    }

    attributes[:condition] = 'Excellente' if tr.css("td:eq(#{3+offset})").text.downcase().include?('x')
    attributes[:condition] = 'Bonne' if tr.css("td:eq(#{4+offset})").text.downcase().include?('x')
    
    # Fix for "passable" but not "open"
    attributes[:ouvert] = true if attributes[:condition] == 'Bonne'
    
    return attributes
  end
end
