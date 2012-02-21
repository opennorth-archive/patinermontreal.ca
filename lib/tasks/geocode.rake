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
    Arrondissement.where(nom_arr: 'Rosemont—La Petite-Patrie').first.patinoires.where(parc: 'Beaubien').each do |patinoire|
      patinoire.update_attribute :adresse, '6633, 6e Avenue'
    end

    { # no address at cotesaintluc.org
      'Irving Singerman'         => '6610 Chemin Merton',
      'Pierre Elliott Trudeau'   => '5891 Avenue Stephen Leacock',
      'Richard Schwartz'         => '5515 Avenue Smart',
      # only in donnees.ville.montreal.qc.ca
      'Camille'                  => '9309 Boulevard Gouin Ouest',
      'Luigi-Pirandello'         => '4550, rue Compiègne',
      'Marcel-Laurin'            => '2345, boulevard Thimens',
      'Polyvalente Saint-Henri'  => '4125 Rue Saint-Jacques',
      'Rosewood'                 => '237 Avenue de Mount Vernon',
      'de Normanville'           => '7470 Rue de Normanville',
      # extra rink in donnees.ville.montreal.qc.ca
      'Beaudet'                  => 'coin rue Du Collège et Boulevard Décarie',
      'Berthe-Louard'            => '9355, avenue De Galinée',
      'Dunkerque'                => '2905 Jean-Talon Ouest',
      'François-Perrault'        => '7501, rue François-Perrault',
      'Saint-Paul-de-la-Croix'   => '9900, avenue Hamel',
      'Walter-Stewart'           => '2455, rue Larivière',
      # no address in Sherlock
      'Bassin Bonsecours'        => '350 de la Commune Ouest',
      'Saint-Léonard'            => '8255, boulevard Lacordaire',
      # useless address in Sherlock
      'Terrasse Jacques-Léonard' => 'Terrasse Jacques Léonard',
      # ignored in Sherlock
      'Sir-Wilfrid-Laurier'      => '1115, avenue Laurier Est',
    }.each do |parc,adresse|
      # @note need to be careful, as park names are not unique
      Patinoire.where(parc: parc).each do |patinoire|
        patinoire.update_attribute :adresse, adresse
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
end
