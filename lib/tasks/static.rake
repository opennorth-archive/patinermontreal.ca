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

      row.delete('nom_arr')
      row.delete('extra')
      row.delete('source_url')

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_disambiguation_and_arrondissement_id(row['parc'], row['genre'], row['disambiguation'], arrondissement.id)
      patinoire.attributes = row.to_hash
      patinoire.source = 'docs.google.com'
      patinoire.save!
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
end
