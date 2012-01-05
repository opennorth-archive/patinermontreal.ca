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
    { # no address at cotesaintluc.org
      'Irving Singerman'         => '6610 Chemin Merton',
      'Pierre Elliott Trudeau'   => '5891 Avenue Stephen Leacock',
      'Richard Schwartz'         => '5515 Avenue Smart',
      # only in donnees.ville.montreal.qc.ca
      'Polyvalente Saint-Henri'  => '4125 Rue Saint-Jacques',
      'Rosewood'                 => '237 Avenue de Mount Vernon',
      'Camille'                  => '9309 Boulevard Gouin Ouest',
      'de Normanville'           => '7470 Rue de Normanville',
      # extra rink in donnees.ville.montreal.qc.ca
      'Saint-Paul-de-la-Croix'   => '9900, avenue Hamel',
      'Berthe-Louard'            => '9355, avenue De Galinée',
      'François-Perrault'        => '7501, rue François-Perrault',
      # no address in Sherlock
      'Saint-Léonard'            => '8255, boulevard Lacordaire',
      'Bassin Bonsecours'        => '350 de la Commune Ouest',
      # useless address in Sherlock
      'Terrasse Jacques-Léonard' => 'Terrasse Jacques Léonard',
      # ignored in Sherlock
      'Sir-Wilfred-Laurier'      => '1115, avenue Laurier Est',
    }.each do |parc,adresse|
      Patinoire.where(parc: parc, adresse: nil).each do |patinoire|
        patinoire.update_attribute :adresse, adresse
      end
    end
  end

  # Geocommons has wrong coordinates for some rinks.
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

  # http://www.ville.ddo.qc.ca/en/googlemap_arenas.html
  desc 'Import table from Google Spreadsheets'
  task :import => :environment do
    require 'csv'
    require 'open-uri'
    CSV.parse(open('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtzgYYy0ZABtdEgwenRMR2MySmU5NFBDVk5wc1RQVEE&single=true&gid=2&output=csv').read, headers: true) do |row|
      if row['lat'] && row['lng']
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
  # Some Google-geocoded addresses will not be close to manually-geocoded rinks
  # because the park is big or the address is bad or approximate.
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
