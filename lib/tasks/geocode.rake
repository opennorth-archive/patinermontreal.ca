# coding: utf-8
namespace :location do
  def clean_address(address)
    {
      '/' => ' & ',
      /\b(coin|entre|et)\b/ => '&',
      /\A(coin|derrière l'aréna,) / => '', # remove needless words
      /, (L'Île-Bizard|PAT|RDP|Roxboro|Sainte-Geneviève)\b/ => '', # remove arrondissement
    }.reduce(address) do |string,(from,to)|
      string.gsub(from, to)
    end.sub(/(.+)(?:,| &) (.+) & (.+)/, '\1 & \2')
  end

  desc 'Add missing addresses and coordinates'
  task :fix => :environment do
    # Add addresses to Sherlock and donnees.ville.montreal.qc.ca rinks
    # @todo club pêcheurs/chasseurs
    { 'Bassin Bonsecours'        => '350 rue St-Paul Est', # no address in Sherlock
      'Berthe-Louard'            => '9355, avenue De Galinée', # extra rink in donnees.ville.montreal.qc.ca
      'Camille'                  => '9309 Boulevard Gouin Ouest', # only in donnees.ville.montreal.qc.ca
      'François-Perrault'        => '7501, rue François-Perrault', # extra rink in donnees.ville.montreal.qc.ca
      'Polyvalente Saint-Henri'  => '4125 Rue Saint-Jacques', # only in donnees.ville.montreal.qc.ca
      'Rosewood'                 => '237 Avenue de Mount Vernon', # only in donnees.ville.montreal.qc.ca
      'Saint-Léonard'            => '8255, boulevard Lacordaire', # no address in Sherlock
      'Saint-Paul-de-la-Croix'   => '9900, avenue Hamel', # extra rink in donnees.ville.montreal.qc.ca
      'Terrasse Jacques-Léonard' => 'Terrasse Jacques Léonard', # useless address in Sherlock
    }.each do |parc,adresse|
      Patinoire.where(parc: parc, adresse: nil).each do |patinoire|
        patinoire.update_attribute :adresse, adresse
      end
    end

    # Add coordinates to Dollard-des-Ormeaux rinks
    # http://www.ville.ddo.qc.ca/en/googlemap_arenas.html
    { 'Coolbrooke'         => '45.4985265013565,-73.79211902618408',
      'du Centenaire'      => '45.486884125312414,-73.81670951843262',
      'Edward Janiszewski' => '45.48671112612774,-73.83962631225586',
      'Elmpark'            => '45.4672039420346,-73.84403586387634',
      'Fairview'           => '45.474690142815035,-73.82806062698364',
      'France'             => '45.498906267013766,-73.82953584194183',
      'Frédérick-Wilson'   => '45.490013062333524,-73.83061408996582',
      'Lake Road'          => '45.48285235405571,-73.8306999206543',
      'Pinecrest'          => '45.499579310747755,-73.82003545761108',
      'Spring Garden'      => '45.49272065600522,-73.7858533859253',
      'Sunnybrooke'        => '45.494736224553186,-73.7977409362793',
      'Terry-Fox'          => '45.496120005970226,-73.82336139678955',
      'Thornhill'          => '45.4788466239341,-73.8197672367096',
      'Trottier'           => '45.50304968230515,-73.82055580615997',
      'Westminster'        => '45.47355411001363,-73.84531259536743',
      'Westwood'           => '45.48899015973809,-73.7934923171997',
    }.each do |parc,coordinates|
      arrondissement = Arrondissement.find_by_nom_arr! 'Dollard-des-Ormeaux'
      lat, lng = coordinates.split(',').map(&:to_f)
      Patinoire.where(parc: parc, arrondissement_id: arrondissement.id).each do |patinoire|
        patinoire.update_attributes lat: lat, lng: lng
      end
    end
  end

  desc 'Geocode rinks using GeoCommons data'
  task :geocommons => :environment do
    require 'csv'
    require 'open-uri'
    CSV.parse(open('http://geocommons.com/overlays/14564.csv'), headers: true).select{|row|
      # Select only outdoor rinks.
      row['name'][/\b(Rink|Patinoire)\b/] &&
      # Get just the rinks near Montreal.
      45.4 <= row['latitude'].to_f && row['latitude'].to_f <= 45.71 && -73.98 <= row['longitude'].to_f && row['longitude'].to_f <= -73.47
    }.each do |row|
      # Correct names from Geocommons.
      parc = {
        'd`a-Ma-Baie' => 'À-Ma-Baie',
        'de la Rive-Boisee' => 'de la Rive-Boisée',
        'Garibaldi' => 'Guiseppe-Garibaldi',
        'Heritage' => 'Héritage',
        'Seguin' => 'Séguin',
      }.reduce(row['name']) do |string,(from,to)|
        string.sub(from, to)
      end.gsub(/\A(Parc|Patinoire) | (Park Rink|Rink)\z/, '').decode_html_entities

      # Add coordinates to matching rinks.
      patinoires = Patinoire.where(parc: parc).all
      if patinoires.empty?
        puts %(No rinks with parc "#{parc}")
      elsif patinoires.all?(&:geocoded?)
        puts %(Already geocoded rinks in "#{parc}")
      else
        patinoires.each do |patinoire|
          patinoire.update_attributes lat: row['latitude'].to_f, lng: row['longitude'].to_f
        end
      end
    end
  end

  # Geocommons has wrong coordinates for:
  # Grier: actually Hermitage
  # Hermitage: actually Lakeside (Ovide)
  # Outremont
  desc 'Compare manual geocoding to official geocoding'
  task :compare => :environment do
    require 'csv'
    require 'open-uri'
    CSV.parse(open('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtzgYYy0ZABtdEgwenRMR2MySmU5NFBDVk5wc1RQVEE&single=true&gid=2&output=csv').read, headers: true) do |row|
      matches = Arrondissement.where(nom_arr: row['nom_arr']).first.patinoires.where(parc: row['parc'], genre: row['genre'], disambiguation: row['disambiguation']).all
      if matches.size > 1
        puts %(#{row['nom_arr']}: #{row['parc']} (#{row['genre']})#{" #{row['note']}" if row['note']} matches many rinks)
      elsif matches.size == 0
        puts %(#{row['nom_arr']}: #{row['parc']} (#{row['genre']})#{" #{row['note']}" if row['note']} matches no rinks)
      elsif matches.first.geocoded?
        patinoire = matches.first
        total = ((patinoire.lat - row['lat'].to_f).abs + (patinoire.lng - row['lng'].to_f).abs).round(5)
        if total > 0.0015
          puts "#{patinoire.nom} #{patinoire.lat},#{patinoire.lng} differs from #{row['lat']},#{row['lng']} by #{(patinoire.lat - row['lat'].to_f).abs},#{(patinoire.lng - row['lng'].to_f).abs} (#{total} total)"
        else
          puts "#{patinoire.nom} is close (#{total})"
        end
      end
    end
  end

  desc 'Import table from Google Spreadsheets'
  task :import => :environment do
    require 'csv'
    require 'open-uri'
    CSV.parse(open('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtzgYYy0ZABtdEgwenRMR2MySmU5NFBDVk5wc1RQVEE&single=true&gid=2&output=csv').read, headers: true) do |row|
      matches = Arrondissement.where(nom_arr: row['nom_arr']).first.patinoires.where(parc: row['parc'], genre: row['genre'], disambiguation: row['disambiguation']).all
      if matches.size > 1
        puts %(#{row['nom_arr']}: #{row['parc']} (#{row['genre']})#{" #{row['note']}" if row['note']} matches many rinks)
      elsif matches.size == 0
        puts %(#{row['nom_arr']}: #{row['parc']} (#{row['genre']})#{" #{row['note']}" if row['note']} matches no rinks)
      else
        matches.first.update_attributes lat: row['lat'].to_f, lng: row['lng'].to_f
      end
    end
  end

  desc 'Export table for Google Spreadsheets'
  task :export => :environment do
    require 'csv'
    parser = URI::Parser.new
    CSV.open('export.csv', 'wb', col_sep: "\t") do |csv|
      csv << %w(nom_arr parc genre disambiguation google)
      Patinoire.includes(:arrondissement).order(:parc, :disambiguation, :genre).each do |patinoire|
        nom_arr = patinoire.arrondissement.nom_arr

        row = [patinoire.arrondissement.nom_arr, patinoire.parc, patinoire.genre, patinoire.disambiguation]
        if patinoire.adresse?
          raw_q = clean_address(patinoire.adresse)
          q = parser.escape("#{raw_q}, #{nom_arr}", /[^#{URI::PATTERN::UNRESERVED}]/)
          row << "http://maps.google.com/maps?q=#{q}"
        end
        csv << row
      end
    end
  end

  # @note Manual geocoding is preferred to avoid stacking.
  #
  # Some Google-geocoded addresses will not be close to manually-geocoded rinks.
  #
  # Big parks:
  # Daniel-Johnson
  # Elgar
  # Eugène-Dostie
  # François-Perrault
  # Jarry
  # Jeanne-Mance
  # Maisonneuve
  # Sir-Wilfrid-Laurier
  #
  # Bad addresses:
  # De Gaspé
  # de l'école Dalpé-Viau
  # de la Savane
  # du Centenaire
  # Hans-Selye (Marc-Aurèle-Fortin)
  # Lucie-Bruneau
  # Marcel-Laurin
  # Noël-Sud
  # Petite Italie (Martel)
  # Rockhill
  # Saint-André-Apôtre
  # Saint-Léonard
  #
  # Approximate addresses:
  # Duff Court
  desc 'Geocode rinks using addresses'
  task :geocode => :environment do
    require 'open-uri'
    cache = {}
    parser = URI::Parser.new
    Patinoire.nongeocoded.where('adresse IS NOT NULL').includes(:arrondissement).each do |patinoire|
      nom_arr = patinoire.arrondissement.nom_arr
      raw_q = clean_address(patinoire.adresse)
      q = parser.escape("#{raw_q}, #{nom_arr}", /[^#{URI::PATTERN::UNRESERVED}]/)

      request = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&language=fr&bounds=45.40,-73.98%7C45.71,-73.47&region=ca&address=#{q}"
      response = cache[request] || ActiveSupport::JSON.decode(open(request).read)
      cache[request] = response

      if response['status'] == 'OK'
        results = response['results'].select{|result| result['address_components'].select{|component| %w(Communauté-Urbaine-de-Montréal Montréal Montreal).include? component['long_name'] }.present? }
        if results.size == 1
          result = results.first
          response_nom_arr       = result['address_components'].find{|x| x['types'].include? 'locality'}['long_name']
          response_street_number = result['address_components'].find{|x| x['types'].include? 'street_number'}.andand['long_name']
          response_route         = result['address_components'].find{|x| x['types'].include? 'route'}.andand['long_name']

          # Tidy Google borough names.
          response_nom_arr = {
            "L'Île-Bizard" => "L'Île-Bizard—Sainte-Geneviève",
            'Sainte-Geneviève' => "L'Île-Bizard—Sainte-Geneviève",
            'Pierrefonds' => 'Pierrefonds-Roxboro',
            'Roxboro' => 'Pierrefonds-Roxboro',
          }.reduce(response_nom_arr) do |string,(from,to)|
            string.sub(from, to)
          end

          # Tidy Google street names.
          if response_route
            response_route = {
              'Alexis Carrel' => 'Alexis-Carrel',
              'André Ampère' => 'André-Ampère',
              'Beaubien Est' => 'Beaubien', # no such thing as Ouest
              'Bishop Power' => 'Bishop-Power',
              'Calixa Lavallée' => 'Calixa-Lavallée',
              'de la Rive Boisée' => 'de la Rive-Boisée',
              'de Saint Firmin' => 'de Saint-Firmin',
              'Elizabeth' => 'Élizabeth',
              'Émile Legrand' => 'Émile-Legrand',
              'François Perrault' => 'François-Perrault',
              'Gabrielle Roy' => 'Gabrielle-Roy',
              'Jean Gascon' => 'Jean-Gascon',
              'Marie le Ber' => 'Marie-Le Ber',
              'P M Favier' => 'P.-M.-Favier',
              'Saint Antoine' => 'Saint-Antoine',
              'Saint Dominique' => 'Saint-Dominique',
              'Saint Jean Baptiste' => 'Saint-Jean-Baptiste',
              'Saint Kevin' => 'Saint-Kevin',
              'Saint Louis' => 'Saint-Louis',
              'Saint Pierre' => 'Saint-Pierre',
            }.reduce(response_route) do |string,(from,to)|
              string.sub(from, to)
            end
          end

          if response_route.nil?
            puts %(No route for #{raw_q})
          elsif response_street_number.nil? && raw_q[/\d/]
            puts %(No street number for #{raw_q})
          elsif response_nom_arr != 'Montréal' && !response_nom_arr[/#{Regexp.escape nom_arr}/i]
            puts %("#{response_nom_arr}" doesn't match "#{nom_arr}")
          elsif !response_street_number.nil? && !raw_q[/\A#{Regexp.escape response_street_number}\b/]
            puts %("#{response_street_number}" doesn't match "#{raw_q}")
          elsif !raw_q[/#{Regexp.escape response_route}/i]
            puts %("#{response_route}" doesn't match "#{raw_q}")
          else
            patinoire.update_attributes lat: result['geometry']['location']['lat'], lng: result['geometry']['location']['lng']
          end
        else
          puts "Too many results for #{raw_q}"
        end
      else
        puts "#{response['status']}"
      end
    end
  end
end
