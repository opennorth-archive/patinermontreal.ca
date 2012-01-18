# coding: utf-8
namespace :import do
  # Imports rinks straight-forwardly from spreadsheet.
  desc 'Add rinks from Google Spreadsheets'
  task :google => :environment do
    require 'csv'
    require 'open-uri'
    CSV.parse(open('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtzgYYy0ZABtdEgwenRMR2MySmU5NFBDVk5wc1RQVEE&single=true&gid=0&output=csv').read, headers: true) do |row|
      arrondissement = Arrondissement.find_or_initialize_by_nom_arr row['nom_arr']
      arrondissement.source = 'docs.google.com'
      arrondissement.save!

      row.delete('nom_arr')
      row.delete('extra')
      row.delete('source_url')

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_disambiguation_and_arrondissement_id row['parc'], row['genre'], row['disambiguation'], arrondissement.id
      patinoire.attributes = row.to_hash
      patinoire.source = 'docs.google.com'
      patinoire.save!
    end
  end

  desc 'Add contact info from Google Spreadsheets'
  task :contacts => :environment do
    require 'csv'
    require 'open-uri'
    CSV.parse(open('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtzgYYy0ZABtdFMwSF94MjRxcW1yZ1JYVkdqM1Fzanc&single=true&gid=0&output=csv').read, headers: true) do |row|
      arrondissement = Arrondissement.find_or_initialize_by_nom_arr row['Authority']
      arrondissement.attributes = {
        name: [row['Name'], row['Title']].compact.join(', '),
        email: row['Email'],
        tel: row['Phone'] && row['Phone'].sub(/x\d+/, '').gsub(/\D/, ''),
        ext: row['Phone'] && row['Phone'][/x(\d+)/, 1],
      }
      arrondissement.source ||= 'docs.google.com'
      arrondissement.save!
    end
  end

  desc 'Add rinks from Sherlock and add addresses to rinks from donnees.ville.montreal.qc.ca'
  task :sherlock => :environment do
    require 'iconv'
    require 'open-uri'

    TEL_REGEX = /\d{3}.?\d{3}.?\d{4}/
    GENRE_REGEX = /C|PP|PPL|PSE|anneau de glace|étang avec musique|rond de glace|patinoire réfrigérée du Canadien de Montréal/

    # List of boroughs represented on donnees.ville.montreal.qc.ca
    ARRONDISSEMENTS_FROM_XML = Arrondissement.where(source: 'donnees.ville.montreal.qc.ca').all.map(&:nom_arr)

    def update_patinoires(arrondissement, attributes, text)
      # Find the rink to update.
      matches = Patinoire.where(attributes.slice(:parc, :genre, :disambiguation).merge(arrondissement_id: arrondissement.id)).all

      # If no rink found, switch PP for PPL.
      if matches.empty? && ARRONDISSEMENTS_FROM_XML.include?(arrondissement.nom_arr)
        matches = Patinoire.where(attributes.slice(:parc, :disambiguation).merge(genre: attributes[:genre] == 'PP' ? 'PPL' : 'PP', arrondissement_id: arrondissement.id)).all
      end

      # If single match found, just update address.
      if matches.size > 1
        puts %("#{text}" matches many rinks)
      elsif attributes[:parc] == 'Sir-Wilfrid-Laurier'
        # @note Sherlock uses nord, sud, but XML uses no 1, no 2, no 3. Do nothing.
      elsif matches.size == 1
        matches.first.update_attributes attributes.slice(:adresse, :tel, :ext).select{|k,v| v.present?}
        # Special case.
        if text[/2 PSE/]
          Patinoire.where(attributes.slice(:parc, :genre).merge(arrondissement_id: arrondissement.id, disambiguation: 'no 2')).first.update_attributes attributes.slice(:adresse, :tel, :ext).select{|k,v| v.present?}
        end
      elsif matches.empty?
        # There's only one rink in Pratt park. vleduc@ville.montreal.qc.ca
        unless attributes[:parc] == 'Pratt'
          # donnees.ville.montreal.qc.ca should generally have all a borough's rinks.
          if ARRONDISSEMENTS_FROM_XML.include?(arrondissement.nom_arr)
            puts %("#{text}" matches no rink. Creating!)
          end
          arrondissement.patinoires.create! attributes.slice(:genre, :disambiguation, :parc, :adresse, :tel, :ext).merge(source: 'ville.montreal.qc.ca')
        end
      end
    end

    nom_arr = nil
    tel = nil
    ext = nil
    flip = 1

    # As the source data is poorly formatted, go line by line with regex.
    open('http://www11.ville.montreal.qc.ca/sherlock2/servlet/template/sherlock%2CAfficherDocumentInternet.vm/nodocument/154').each do |line|
      line = Iconv.conv('UTF-8', 'ISO-8859-1', line).gsub(/[[:space:]]/, ' ').decode_html_entities.chomp
      text = ActionController::Base.helpers.strip_tags(line)

      # If it's a borough header:
      if match = line[%r{<strong>([^<]+)</strong>.+\d+ patinoires}, 1]
        nom_arr = match.gsub("\u0096", '—') # fix dashes
        tel = line[TEL_REGEX]
        ext = line[/poste (\d+)/, 1]
      else
        attributes = {}
        # If it's a rink:
        if genre = line[/[^>]\b(#{GENRE_REGEX})\b/, 1]
          attributes = {
            genre:          genre,
            tel:            text[TEL_REGEX] || tel,
            ext:            ext,
            parc:           text[/\A([^(,*]+)/, 1].andand.strip,
            adresse:        text[/,(?: \()?((?:[^()](?! 514))+)/, 1].andand.strip,
            patinoire:      text[/\bet \(?(#{GENRE_REGEX})\)/, 1].andand.strip,
            disambiguation: text[/\((nord|sud|petite|grande)\)/, 1].andand.strip,
            extra:          text.scan(/\((1 M|LA|abri|cabane|chalet|chalet fermé|chalet pas toujours ouvert|pas de chalet|roulotte|toilettes)\)/).flatten.map(&:strip),
          }
        # If it's a rink, with no rink type specified:
        elsif line[/\A(Parc <strong>|<strong>Bassin\b)/]
          attributes = {
            parc:    text[/\A([^(,*]+)/, 1].andand.strip,
            adresse: text[/,(?: \()?((?:[^()](?! 514))+)/, 1].andand.strip,
            extra:   [],
          }
        end

        unless attributes.empty?
          raw = Marshal.load(Marshal.dump(attributes)) # deep copy

          # Append attributes.
          if text['*']
            attributes[:disambiguation] = 'réfrigérée'
          end
          if attributes[:genre] == 'étang avec musique'
            attributes[:extra] << 'musique'
          end
          # From joseeboudreau@ville.montreal.qc.ca
          if %w(Gohier Hartenstein).include? attributes[:parc]
            attributes[:extra] << 'glissade'
          end
          if text[/réfrigérée/]
            attributes[:description] = 'Patinoire réfrigérée'
            attributes[:disambiguation] = 'réfrigérée'
          end

          # Clean attributes.
          attributes[:parc].slice!(/\A(Parc|Patinoire) /)
          if attributes[:parc][Patinoire::PREPOSITIONS]
            attributes[:parc][Patinoire::PREPOSITIONS] = attributes[:parc][Patinoire::PREPOSITIONS].downcase
          end
          if attributes[:tel]
            attributes[:tel].delete!('^0-9')
          end

          # Map attributes.
          if attributes[:patinoire] == 'rond de glace'
            attributes[:patinoire] = 'PPL'
          end
          attributes[:extra].map! do |v|
            {'1 M' => 'musique', 'LA' => 'location et aiguisage'}[v] || v
          end
          attributes[:genre] = {
            'anneau de glace'                              => 'PP', # Daniel-Johnson
            'étang avec musique'                           => 'PP', # Jarry
            'rond de glace'                                => 'PPL',
            'patinoire réfrigérée du Canadien de Montréal' => 'PSE',
          }[attributes[:genre]] || attributes[:genre]
          attributes[:parc] = {
            'Bleu Blanc Bouge Le Carignan'     => 'Le Carignan',
            'Bleu Blanc Bouge de Saint-Michel' => 'François-Perrault',
            'Bleu Blanc Bouge'                 => 'Willibrord', # must be after above
            "de l'école Dalpé-Viau"            => 'école Dalbé-Viau',
            'de Kent'                          => 'Kent',
            'Lasalle'                          => 'LaSalle',
            'Pierre-E.-Trudeau'                => 'Pierre-E-Trudeau',
            "Terrain de piste et pelouse attenant à l'aréna Martin-Brodeur" => 'Saint-Léonard',
          }[attributes[:parc]] || attributes[:parc]

          # Special case.
          if text[/2 PSE/] || text == "Parc Beaubien, 6633, 6e Avenue (PSE) (chalet) "
            attributes[:disambiguation] = 'no 1'
          end
          # There are identical lines in Sherlock.
          if (attributes[:parc] == 'Eugène-Dostie' && attributes[:genre] == 'PSE') || (attributes[:parc] == 'Alexander' && attributes[:genre] == 'PPL') || (attributes[:parc] == 'À-Ma-Baie' && attributes[:genre] == 'PPL')
            attributes[:disambiguation] = "no #{flip}"
            flip = flip == 1 ? 2 : 1
          end

          # Sherlock has useless address.
          if attributes[:adresse] == 'PAT'
            attributes[:adresse] = nil
          end

          # Sherlock has the wrong rink type.
          attributes[:genre] = case attributes[:parc]
          when 'Maurice-Cullen'
            'PPL'
          when 'Champdoré'
            'PSE'
          when 'Chamberland'
            'PSE' # from joseeboudreau@ville.montreal.qc.ca
          when 'Kent'
            if attributes[:disambiguation].nil?
              'PPL'
            else
              attributes[:genre]
            end
          when 'Oakwood'
            'PPL'
          when 'Van Horne'
            'PP'
          else
            attributes[:genre]
          end

          # Fill in missing genre.
          if ['Pilon', 'Saint-Léonard', 'Bassin Bonsecours'].include? attributes[:parc]
            attributes[:genre] ||= 'PPL'
          end

          # Fix dashes.
          nom_arr = {
            'Côte-des-Neiges–Notre-Dame-de-Grâce'      => 'Côte-des-Neiges—Notre-Dame-de-Grâce',
            "L'Île-Bizard–Sainte-Geneviève"            => "L'Île-Bizard—Sainte-Geneviève",
            'Mercier–Hochelaga-Maisonneuve'            => 'Mercier—Hochelaga-Maisonneuve',
            'Rivière-des-Prairies–Pointe-aux-Trembles' => 'Rivière-des-Prairies—Pointe-aux-Trembles',
            'Rosemont–La Petite-Patrie'                => 'Rosemont—La Petite-Patrie',
            'Villeray–Saint-Michel–Parc-Extension'     => 'Villeray—Saint-Michel—Parc-Extension',
          }[nom_arr] || nom_arr

          # Create boroughs and rinks.
          arrondissement = Arrondissement.find_or_initialize_by_nom_arr nom_arr
          arrondissement.source ||= 'ville.montreal.qc.ca'
          arrondissement.save!

          update_patinoires arrondissement, attributes, text
          if attributes[:patinoire]
            update_patinoires arrondissement, attributes.merge(genre: attributes[:patinoire]), text
          end

          # Check if any text has been omitted from extraction.
          rest = raw.reduce(text.dup) do |s,(_,v)|
            if Array === v
              v.each do |x|
                s.sub!(x, '')
              end
            elsif v
              s.sub!(v, '')
            end
            s
          end.sub(%r{\bet\b|\((demi-glace|anciennement Marc-Aurèle-Fortin|Habitations Jeanne-Mance|lac aux Castors|Paul-Émile-Léger|rue D'Iberville/rue de Rouen|St-Anthony)\)}, '').gsub(/\p{Punct}/, '').strip

          puts %(didn't extract "#{rest}" from "#{text}") unless rest.empty?
        end
      end
    end
  end
end
