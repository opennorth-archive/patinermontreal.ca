# coding: utf-8
namespace :import do
  # Imports rinks straight-forwardly from spreadsheet.
  desc 'Add rinks from Google Spreadsheets'
  task :static => :environment do
    require 'csv'
    require 'open-uri'
    CSV.parse(open('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtzgYYy0ZABtdEgwenRMR2MySmU5NFBDVk5wc1RQVEE&single=true&gid=0&output=csv').read, headers: true) do |row|
      arrondissement = Arrondissement.find_or_initialize_by_nom_arr row['nom_arr']
      arrondissement.source = 'docs.google.com'
      arrondissement.save!

      row.delete('nom_arr')
      row.delete('extra')
      row.delete('source_url')

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id row['parc'], row['genre'], arrondissement.id
      patinoire.attributes = row.to_hash
      patinoire.source = 'docs.google.com'
      patinoire.save!
    end
  end

  desc 'Add rinks from Sherlock and add addresses to rinks from donnees.ville.montreal.qc.ca'
  task :sherlock => :environment do
    require 'iconv'
    require 'open-uri'

    TEL_REGEX = /\d{3}.?\d{3}.?\d{4}/
    GENRE_REGEX = /C|PP|PPL|PSE|anneau de glace|étang avec musique|rond de glace|patinoire réfrigérée du Canadien de Montréal/

    # List of boroughs represented on donnees.ville.montreal.qc.ca
    ARRONDISSEMENT_XML = [
      'Ahuntsic-Cartierville',
      'Côte-des-Neiges—Notre-Dame-de-Grâce',
      'Le Plateau-Mont-Royal',
      'Le Sud-Ouest',
      'Mercier—Hochelaga-Maisonneuve',
      'Rivière-des-Prairies—Pointe-aux-Trembles',
      'Rosemont—La Petite-Patrie',
      'Ville-Marie',
      'Villeray—Saint-Michel—Parc-Extension',
    ]

    def update_patinoires(arrondissement, attributes, text)
      # Find the rink to update
      matches = Patinoire.where(attributes.slice(:parc, :genre, :disambiguation).merge(arrondissement_id: arrondissement.id)).all
      if matches.empty? && ARRONDISSEMENT_XML.include?(arrondissement.nom_arr)
        matches = Patinoire.where(attributes.slice(:parc, :disambiguation).merge(genre: attributes[:genre] == 'PP' ? 'PPL' : 'PP', arrondissement_id: arrondissement.id)).all
      end

      # If single match found, just update address.
      if matches.size > 1
        puts %("#{text}" matches many rinks)
      elsif attributes[:parc] == 'Sir-Wilfrid-Laurier'
        # @note Sherlock uses nord, sud, but XML uses no 1, no 2, no 3. Do nothing.
      elsif matches.size == 1
        matches.first.update_attributes attributes.slice(:adresse, :tel, :ext).select{|k,v| v.present?}
      elsif matches.empty?
        # donnees.ville.montreal.qc.ca should generally have all a borough's rinks.
        if ARRONDISSEMENT_XML.include?(arrondissement.nom_arr)
          puts %("#{text}" matches no rink. Creating!)
        end

        args = attributes.slice(:genre, :disambiguation, :parc, :adresse, :tel, :ext)
        args[:source] = 'ville.montreal.qc.ca'

        # Special case.
        if text[/2 PSE/]
          %w(1 2).each{|num| arrondissement.patinoires.create! args.merge(disambiguation: "no #{num}")}
        else
          arrondissement.patinoires.create! args
        end
      end
    end

    nom_arr = nil
    tel = nil
    ext = nil
    flip = 1

    # As the source data is poorly formatted, go line by line with regex.
    open('http://www11.ville.montreal.qc.ca/sherlock2/servlet/template/sherlock%2CAfficherDocumentInternet.vm/nodocument/154').each do |line|
      line = Iconv.conv('UTF-8', 'ISO-8859-1', line).decode_html_entities.chomp
      text = ActionController::Base.helpers.strip_tags(line)

      # If it's a borough header:
      if match = line[%r{<strong>([^<]+)</strong>.+\d+ patinoires}, 1]
        nom_arr = match.gsub('–', '—') # change n-dash to m-dash
        tel = line[TEL_REGEX]
        ext = line[/poste (\d+)/, 1]
      # If it's a rink:
      elsif genre = line[/[^>]\b(#{GENRE_REGEX})\b/, 1]
        raw = {
          genre:          genre,
          tel:            text[TEL_REGEX] || tel,
          ext:            ext,
          parc:           text[/\A([^(,*]+)/, 1].andand.strip,
          adresse:        text[/,(?: \()?((?:[^()](?! 514))+)/, 1].andand.strip,
          patinoire:      text[/\bet \(?(#{GENRE_REGEX})\)/, 1].andand.strip,
          disambiguation: text[/\((nord|sud|petite|grande)\)/, 1].andand.strip,
          extra:          text.scan(/\((1 M|LA|abri|cabane|chalet|chalet fermé|chalet pas toujours ouvert|pas de chalet|roulotte|toilettes)\)/).flatten.map(&:strip),
        }

        attributes = Marshal.load(Marshal.dump(raw)) # deep copy

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
          'anneau de glace' => 'PP', # Daniel-Johnson
          'étang avec musique' => 'PP', # Jarry
          'rond de glace' => 'PPL',
          'patinoire réfrigérée du Canadien de Montréal' => 'PSE',
        }[attributes[:genre]] || attributes[:genre]

        # Special case.
        if text[/2 PSE/]
          attributes[:disambiguation] = 'no 1'
        end
        # There are identical lines in Sherlock.
        if (attributes[:parc] == 'Eugène-Dostie' && attributes[:genre] == 'PSE') || (attributes[:parc] == 'Alexander' && attributes[:genre] == 'PPL') || (attributes[:parc] == 'À-Ma-Baie' && attributes[:genre] == 'PPL')
          attributes[:disambiguation] = "no #{flip}"
          flip = flip == 1 ? 2 : 1
        end

        # Sherlock has the wrong park name.
        attributes[:parc] = case attributes[:parc]
        when 'Bleu Blanc Bouge de Saint-Michel'
          'François-Perrault'
        when 'Patinoire Bleu Blanc Bouge Le Carignan'
          'Le Carignan'
        when 'Bleu Blanc Bouge'
          'Willibrord'
        when "Terrain de piste et pelouse attenant à l'aréna Martin-Brodeur"
          'Saint-Léonard'
        else
          attributes[:parc]
        end

        # Sherlock has the wrong rink type.
        attributes[:genre] = case attributes[:parc]
        when 'Champdoré'
          'PSE'
        when 'Chamberland'
          'PSE' # from joseeboudreau@ville.montreal.qc.ca
        when 'de Kent'
          if attributes[:disambiguation].nil?
            'PPL'
          else
            attributes[:genre]
          end
        else
          attributes[:genre]
        end

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

        puts %("#{rest}" unextracted from "#{text}") unless rest.empty?
      # If it's a rink, with no rink type specified:
      elsif line[/\A(Parc <strong>|<strong>Bassin\b)/]
        attributes = {
          parc:    text[/\A([^(,*]+)/, 1].andand.strip,
          adresse: text[/,(?: \()?((?:[^()](?! 514))+)/, 1].andand.strip,
          genre:   'PPL',
        }
        if text['*']
          attributes[:disambiguation] = 'réfrigérée'
        end          
        attributes[:parc].slice!(/\A(Parc|Patinoire) /)

        arrondissement = Arrondissement.find_or_initialize_by_nom_arr nom_arr
        arrondissement.source ||= 'ville.montreal.qc.ca'
        arrondissement.save!

        update_patinoires arrondissement, attributes, text
      end
    end
  end
end
