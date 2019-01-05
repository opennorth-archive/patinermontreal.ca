# coding: utf-8
namespace :import do
  desc 'Add manual rinks from Google Spreadsheets'
  task manual: :environment do
    require 'csv'
    require 'open-uri'
    CSV.parse(open('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtzgYYy0ZABtdEgwenRMR2MySmU5NFBDVk5wc1RQVEE&single=true&gid=0&output=csv', "r:utf-8").read, headers: true) do |row|
      arrondissement = Arrondissement.find_or_initialize_by_nom_arr(row['nom_arr'])
      arrondissement.source = 'docs.google.com'
      arrondissement.save!

      # Manually added Bleu-Blanc-Bouge rinks, based on extra field = "bbb"
      is_bbb = row['extra'] == 'bbb'
      
      row.delete('nom_arr')
      row.delete('extra')
      row.delete('source_url')

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_disambiguation_and_arrondissement_id(row['parc'], row['genre'], row['disambiguation'], arrondissement.id)
      patinoire.attributes = row.to_hash

      # Rename the manually added Bleu-Blanc-Bouge rinks
      if is_bbb
        patinoire.description = 'Patinoire réfrigérée Bleu-Blanc-Bouge'
        # Temporary solution (early december) for refrigerated rinks
#         patinoire.ouvert = true
#         patinoire.condition = 'N/A'
      end
      if row['disambiguation'] == "réfrigérée" 
        patinoire.description = "Patinoire réfrigérée"
        patinoire.ouvert = true
        patinoire.condition = 'N/A'
      end
      
      patinoire.source = 'docs.google.com'
      begin
        patinoire.save!
      rescue => e
        puts "#{e.inspect}: #{patinoire.inspect}"
      end
    end
  end

  desc 'Add contact info from Google Spreadsheets'
  task contacts: :environment do
    require 'csv'
    require 'open-uri'
   CSV.parse(open('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtzgYYy0ZABtdFMwSF94MjRxcW1yZ1JYVkdqM1Fzanc&single=true&gid=0&output=csv', "r:utf-8").read, headers: true) do |row|
      arrondissement = Arrondissement.find_or_initialize_by_nom_arr row['Authority']
      arrondissement.attributes = {
        name: [row['Name'], row['Title']].compact.join(', '),
        email: row['Email'] && row['Email'].strip,
        tel: row['Phone'] && row['Phone'].sub(/x\d+/, '').gsub(/\D/, ''),
        ext: row['Phone'] && row['Phone'][/x(\d+)/, 1],
      }
      arrondissement.source ||= 'docs.google.com'
      arrondissement.save!
    end
  end

  # http://www.ville.ddo.qc.ca/en/googlemap_arenas.html
  desc 'Import address, latitude and longitude from Google Spreadsheets'
  task location: :environment do
    require 'csv'
    require 'open-uri'
    missing = Set.new
    CSV.parse(open('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtzgYYy0ZABtdEgwenRMR2MySmU5NFBDVk5wc1RQVEE&single=true&gid=2&output=csv', "r:utf-8").read, headers: true) do |row|
      if row['lat'] && row['lng']
        arrondissement = Arrondissement.where(nom_arr: row['nom_arr']).first
        if arrondissement
          matches = arrondissement.patinoires.where(parc: row['parc'], genre: row['genre'], disambiguation: row['disambiguation']).all
          if matches.size > 1
            puts %(#{row['nom_arr'].ljust(40)} #{row['parc']} (#{row['genre']})#{" (#{row['disambiguation']})" if row['disambiguation'].present?} matches many rinks)
          elsif matches.size == 0
            missing << %(#{row['nom_arr'].ljust(40)} #{row['parc']} (#{row['genre']})#{" (#{row['disambiguation']})" if row['disambiguation'].present?})
          else
            matches.first.update_attributes adresse: row['adresse'], lat: row['lat'].to_f, lng: row['lng'].to_f
          end
        else
          missing << row['nom_arr']
        end
      end
    end
    unless missing.empty?
      puts "Could not find a borough or rink to match the data from the Google Docs. A dynamic data source may have changed the names of boroughs or rinks, or it may have removed those boroughs or rinks. If the name was changed, the Google Docs must be updated to match, otherwise the rink will not have geocoordinates:"
      missing.each do |nom_arr|
        puts nom_arr.ljust(40)
      end
    end
  end

  task export: :environment do
    require 'csv'
    parser = URI::Parser.new
    CSV.open('export.csv', 'wb', col_sep: "\t") do |csv|
      Patinoire.nongeocoded.includes(:arrondissement).order(:parc, :disambiguation, :genre).each do |patinoire|
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
  
  
  # http://www.patinermontreal.ca/geojson/ (or localhost:3000)
  task geojson: :environment do
    puts "Importing Dollard-des-Ormeaux..."
    import_geojson_for_arrondissement 'http://www.patinermontreal.ca/geojson/dollarddesormeaux.geojson', 'Dollard-des-Ormeaux', 'www.ville.ddo.qc.ca'
    puts "Importing Laval..."
    import_geojson_for_arrondissement 'http://www.patinermontreal.ca/geojson/laval.geojson', 'Laval', 'www.laval.ca'
    puts "Importing Vieux-Longueuil..."
    import_geojson_for_arrondissement 'http://www.patinermontreal.ca/geojson/longueuil.geojson', 'Vieux-Longueuil', 'www.longueuil.quebec'
    puts "Importing Saint-Hubert..."
    import_geojson_for_arrondissement 'http://www.patinermontreal.ca/geojson/sainthubert.geojson', 'Saint-Hubert', 'www.longueuil.quebec'
    puts "Importing Boucherville..."
    import_geojson_for_arrondissement 'http://www.patinermontreal.ca/geojson/boucherville.geojson', 'Boucherville', 'www.boucherville.ca'
    puts "Importing Brossard..."
    import_geojson_for_arrondissement 'http://www.patinermontreal.ca/geojson/brossard.geojson', 'Brossard', 'www.ville.brossard.qc.ca'
    puts "Importing La Prairie..."
    import_geojson_for_arrondissement 'http://www.patinermontreal.ca/geojson/laprairie.geojson', 'La Prairie', 'www.ville.laprairie.qc.ca'
    puts "Importing Candiac..."
    import_geojson_for_arrondissement 'http://www.patinermontreal.ca/geojson/candiac.geojson', 'Candiac', 'candiac.ca'
    puts "Done importing GeoJSON rinks"
  end
  
  
  def import_geojson_for_arrondissement(geojson_uri, nom_arr, source)
    require 'json'
    require 'open-uri'

    arrondissement = Arrondissement.find_or_initialize_by_nom_arr(nom_arr)
    arrondissement.source = source
    arrondissement.save!
    
    collection = JSON.parse(open(geojson_uri, "r:utf-8").read)
    
    collection['features'].each do| feature|
      properties = feature['properties']
      if (properties['deleted']) 
        next
      end
      
      if (properties['nom'] == 'Patinoire Bleu-Blanc-Bouge')
        patinoire = Patinoire.find_or_initialize_by_description_and_parc_and_arrondissement_id('Patinoire réfrigérée Bleu-Blanc-Bouge', properties['parc'], arrondissement.id)
        patinoire.nom = "#{properties['nom']}, #{properties['parc']} (#{properties['genre']})"
        patinoire.genre = properties['genre']
        patinoire.disambiguation = 'réfrigérée'
      else
        patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id properties['parc'].sub('Parc ', ''), properties['genre'], arrondissement.id
      end
      
      patinoire.lng = feature['geometry']['coordinates'][0]
      patinoire.lat = feature['geometry']['coordinates'][1]
      patinoire.adresse = properties['adresse']
      # patinoire.condition = nil
      
      patinoire.source = source
      
      begin
        patinoire.save!
      rescue => e
        puts "#{e.inspect}: #{patinoire.inspect}"
      end
    end
  end
end
