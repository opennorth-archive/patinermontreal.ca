namespace :import do
  task :static => :environment do
    {
      'Beaconsfield' => {
        patinoires: [
          {
            genre: 'PPL',
            parc: 'Beacon Hill',
            adresse: '100, Harwood Gate',
            extra: ['chalet'],
          },
          {
            genre: 'PSE',
            parc: 'Beacon Hill',
            adresse: '100, Harwood Gate',
            extra: ['chalet'],
          },
          {
            genre: 'PPL',
            parc: 'Beaconsfield Heights',
            adresse: 'Evergreen et Park',
            extra: ['chalet'],
          },
          {
            genre: 'PSE',
            parc: 'Beaconsfield Heights',
            adresse: 'Evergreen et Park',
            extra: ['chalet'],
          },
          {
            genre: 'PPL',
            parc: 'Briarwood',
            adresse: '50, Willowbrook',
            extra: ['chalet'],
          },
          {
            genre: 'PSE',
            parc: 'Briarwood',
            adresse: '50, Willowbrook',
            extra: ['chalet'],
          },
          {
            genre: 'PPL',
            parc: 'Christmas',
            adresse: '424, Boul. Beaconsfield',
            extra: ['chalet'],
          },
          {
            genre: 'PSE',
            parc: 'Christmas',
            adresse: '424, Boul. Beaconsfield',
            extra: ['chalet'],
          },
          {
            genre: 'PPL',
            parc: 'Drummond',
            adresse: 'Fieldsend et Farnham',
            extra: ['chalet'],
          },
          {
            genre: 'PSE',
            parc: 'Drummond',
            adresse: 'Fieldsend et Farnham',
            extra: ['chalet'],
          },
          {
            genre: 'PPL',
            parc: 'Highbridge',
            adresse: 'Highridge et Highridge',
          },
          {
            genre: 'PPL',
            parc: 'Lakeview',
          },
          {
            genre: 'PPL',
            parc: 'Montrose',
            adresse: 'Montrose et Elm',
          },
          {
            genre: 'PPL',
            parc: 'Rockhill',
            adresse: '555, Beaurepaire Drive',
            extra: ['chalet'],
          },
          {
            genre: 'PSE',
            parc: 'Rockhill',
            adresse: '555, Beaurepaire Drive',
            extra: ['chalet'],
          },
          {
            genre: 'PPL',
            parc: 'Shannon',
            adresse: 'Preston et Markham',
            extra: ['chalet'],
          },
          {
            genre: 'PSE',
            parc: 'Shannon',
            adresse: 'Preston et Markham',
            extra: ['chalet'],
          },
          {
            genre: 'PPL',
            parc: 'Taywood',
            adresse: 'Taywood et Nassau',
          },
          {
            genre: 'PSE',
            parc: 'Taywood',
            adresse: 'Taywood et Nassau',
          },
          {
            genre: 'PPL',
            parc: 'Windermere',
            adresse: '313, Windermere',
            extra: ['chalet'],
          },
          {
            genre: 'PSE',
            parc: 'Windermere',
            adresse: '313, Windermere',
            extra: ['chalet'],
          },
        ],
      },
      'Côte-Saint-Luc' => {
        patinoires: [
          {
            genre: 'PPL',
            parc: 'Pierre Elliott Trudeau',
            lat: 45.474938,
            lng: -73.670973,
          },
          {
            genre: 'PSE',
            parc: 'Pierre Elliott Trudeau',
            lat: 45.474442,
            lng: -73.669914,
          },
          {
            genre: 'PPL',
            parc: 'Irving Singerman',
            lat: 45.471978,
            lng: -73.652323,
          },
          {
            genre: 'PSE',
            parc: 'Irving Singerman',
            lat: 45.472458,
            lng: -73.652878,
          },
          {
            genre: 'PPL',
            parc: 'Richard Schwartz',
            lat: 45.458340,
            lng: -73.666000,
          },
        ],
        extra: {
          tel: 5144856824,
        }
      },
      'Kirkland' => {
        patinoires: [
          { # http://www.ville.kirkland.qc.ca/client/page2.asp?page=144&clef=8&clef2=11
            genre: 'PSE',
            parc: 'Canvin',
            adresse: '1, rue de Surrey',
            tel: 5146302704,
            lat: 45.447412,
            lng: -73.83791,
          },
          { # http://www.ville.kirkland.qc.ca/client/page2.asp?page=151&clef=8&clef2=11
            genre: 'PPL',
            parc: 'Ecclestone',
            adresse: '130, rue Argyle',
            tel: 5146302718,
            #extra: ['chalet'],
            lat: 45.461907,
            lng: -73.856835,
          },
          { # http://www.ville.kirkland.qc.ca/client/page2.asp?page=155&clef=8&clef2=11
            genre: 'PSE',
            parc: 'Héritage',
            adresse: 'chemin Lantier',
            tel: 5146302703,
            #extra: ['chalet'],
            # corrected
            lat: 45.441239,
            lng: -73.898443,
          },
          { # http://www.ville.kirkland.qc.ca/client/page2.asp?page=156&clef=8&clef2=11
            genre: 'PSE',
            parc: 'Holleuffer',
            adresse: '75, rue Charlevoix',
            tel: 5146302714,
            #extra: ['chalet'],
            # corrected
            lat: 45.450467,
            lng: -73.880075,
          },
          { # http://www.ville.kirkland.qc.ca/client/page2.asp?page=156&clef=8&clef2=11
            genre: 'PSE',
            parc: 'Kirkland',
            adresse: '81, rue Park Ridge',
            tel: 5146302749,
            #extra: ['chalet'],
            # corrected
            lat: 45.444209,
            lng: -73.860484,
          },
        ],
      },
      'Montréal-Ouest' => {
        patinoires: [
          {
            genre: 'PSE',
            parc: 'Hodgson Field',
            adresse: '220 Bedbrook',
            #extra: ['chalet'],
          },
          {
            genre: 'PPL',
            parc: 'Hodgson Field',
            adresse: '220 Bedbrook',
            #extra: ['chalet'],
          },
          {
            genre: 'PSE',
            parc: 'Rugby Park',
            adresse: '28 Rugby',
          },
        ],
      },
      'Pointe-Claire' => {
        patinoires: [
          {
            genre: 'PSE',
            parc: 'Bourgeau',
            adresse: '7 Ste Anne Ave',
            tel: 5146301231,
          },
          {
            genre: 'PSE',
            parc: 'Cedar Park Heights',
            adresse: '20 Robinsdale Ave',
            tel: 5146301232,
          },
          {
            genre: 'PSE',
            parc: 'Clearpoint',
            tel: 5146301233,
          },
          {
            genre: 'PSE',
            parc: 'Hermitage',
            adresse: '400 Hermitage Ave',
            tel: 5146301250,
          },
          {
            genre: 'PSE',
            parc: 'Lakeside (Ovide)',
            adresse: '20 Ovide Ave',
            tel: 5146301235,
          },
          {
            genre: 'PSE',
            parc: 'Northview',
            adresse: '111 Viking Ave',
            tel: 5146301236,
          },
          {
            genre: 'PSE',
            parc: 'Séguin',
            adresse: 'Parc Arthur Seguin',
            tel: 5146301247,
          },
          {
            genre: 'PSE',
            parc: 'Seigniory',
            adresse: 'Seigniory Ave',
            tel: 5146301238,
          },
          {
            genre: 'PSE',
            parc: 'Valois',
            adresse: '85 Belmont Ave',
            tel: 5146301229,
          },
        ],
      },
      'Saint-Laurent' => {
        patinoires: [
          {
            genre: 'PPL',
            parc: 'Beaudet',
            adresse: 'coin rue Du Collège et Boulevard Décarie',
          },
          {
            genre: 'PSE',
            parc: 'Marcel-Laurin',
            adresse: '2345, boulevard Thimens',
          },
          {
            genre: 'PPL',
            parc: 'Marcel-Laurin',
            adresse: '2345, boulevard Thimens',
          },
        ],
        extra: {
          tel: 5148556000,
          ext: 4700,
        }
      },
      'Sainte-Anne-de-Bellevue' => {
        patinoires: [
          {
            genre: 'PPL',
            parc: 'Aumais',
            adresse: '300, rue Cypilot',
          },
          {
            genre: 'PSE',
            parc: 'Aumais',
            adresse: '300, rue Cypilot',
          },
          {
            genre: 'PSE',
            parc: 'Godin',
            adresse: '210, rue Sainte-Anne',
          },
          {
            genre: 'PPL',
            parc: 'Harpell',
            adresse: '60, rue Saint-Pierre',
          },
          {
            genre: 'PSE',
            parc: 'Harpell',
            adresse: '60, rue Saint-Pierre',
          },
        ],
      },
      'Senneville' => {
        patinoires: [
          {
            genre: 'PPL',
            parc: 'Senneville',
            adresse: '20 Morningside',
          },
          {
            genre: 'PPL',
            parc: 'Crevier',
            adresse: '97 chemin Senneville',
          },
          {
            genre: 'PPL',
            parc: 'Michel Legault',
            adresse: '35 Phillips',
          },
        ],
      },
    }.each do |nom_arr,hash|
      arrondissement = Arrondissement.find_or_create_by_nom_arr nom_arr
      hash[:extra] ||= {}
      hash[:patinoires].each do |attributes|
        unless Patinoire.find_by_parc_and_genre_and_arrondissement_id attributes[:parc], attributes[:genre], arrondissement.id
          arrondissement.patinoires.create! attributes.merge(hash[:extra])
        end
      end
    end
  end

  task :sherlock => :environment do
    require 'iconv'
    require 'open-uri'

    TEL_REGEX = /\d{3}.?\d{3}.?\d{4}/
    GENRE_REGEX = /C|PP|PPL|PSE|anneau de glace|étang avec musique|rond de glace|patinoire réfrigérée du Canadien de Montréal/
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

    class String
      # @see http://www.w3.org/TR/html4/sgml/entities.html
      def decode_html_entities
        gsub(/&#(\d+);/) do |match|
          if 160 <= $1.to_i && $1.to_i <= 255
            $1.to_i.chr 'utf-8'
          else
            { '&#8194;' => ' ',
              '&#8195;' => ' ',
              '&#8201;' => ' ',
              '&#8204;' => '‌',
              '&#8205;' => '‍',
              '&#8206;' => '‎',
              '&#8207;' => '‏',
              '&#8211;' => '–',
              '&#8212;' => '—',
              '&#8216;' => '‘',
              '&#8217;' => '’',
              '&#8218;' => '‚',
              '&#8220;' => '“',
              '&#8221;' => '”',
              '&#8222;' => '„',
              '&#8224;' => '†',
              '&#8225;' => '‡',
              '&#8240;' => '‰',
              '&#8249;' => '‹',
              '&#8250;' => '›',
              '&#8364;' => '€',
            }[match]
          end
        end
      end
    end

    def update_patinoires(arrondissement, attributes, text)
      # Find the rink to update
      matches = Patinoire.where(attributes.slice(:parc, :genre, :disambiguation).merge(arrondissement_id: arrondissement.id)).all
      if matches.empty? && ARRONDISSEMENT_XML.include?(arrondissement.nom_arr)
        matches = Patinoire.where(attributes.slice(:parc, :disambiguation).merge(genre: attributes[:genre] == 'PP' ? 'PPL' : 'PP', arrondissement_id: arrondissement.id)).all
      end

      if matches.size > 1
        puts %("#{text}" matches many rinks)
      elsif attributes[:parc] == 'Sir-Wilfrid-Laurier'
        # @note Sherlock uses nord, sud, but XML uses no 1, no 2, no 3. Do nothing.
      elsif matches.size == 1
        matches.first.update_attributes attributes.slice(:adresse, :tel, :ext).select{|k,v| v.present?}
      elsif matches.empty?
        if ARRONDISSEMENT_XML.include?(arrondissement.nom_arr)
          puts %("#{text}" matches no rink. Creating!)
        end

        args = attributes.slice(:genre, :disambiguation, :parc, :adresse, :tel, :ext)

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

    open('http://www11.ville.montreal.qc.ca/sherlock2/servlet/template/sherlock%2CAfficherDocumentInternet.vm/nodocument/154').each do |line|
      line = Iconv.conv('UTF-8', 'ISO-8859-1', line).decode_html_entities.chomp
      text = ActionController::Base.helpers.strip_tags(line)

      if match = line[%r{<strong>([^<]+)</strong>.+\d+ patinoires}, 1]
        nom_arr = match.gsub('–', '—') # change n-dash to m-dash
        tel = line[TEL_REGEX]
        ext = line[/poste (\d+)/, 1]
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

        # Append attributes
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

        # Clean attributes
        attributes[:parc].slice!(/\A(Parc|Patinoire) /)
        if attributes[:parc][Patinoire::PREPOSITIONS]
          attributes[:parc][Patinoire::PREPOSITIONS] = attributes[:parc][Patinoire::PREPOSITIONS].downcase
        end
        if attributes[:tel]
          attributes[:tel].delete!('^0-9')
        end

        # Map attributes
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

        # Special case
        if text[/2 PSE/]
          attributes[:disambiguation] = 'no 1'
        end
        # There are identical lines in Sherlock
        if (attributes[:parc] == 'Eugène-Dostie' && attributes[:genre] == 'PSE') || (attributes[:parc] == 'Alexander' && attributes[:genre] == 'PPL') || (attributes[:parc] == 'À-Ma-Baie' && attributes[:genre] == 'PPL')
          attributes[:disambiguation] = "no #{flip}"
          flip = flip == 1 ? 2 : 1
        end

        # Sherlock has the wrong park name
        attributes[:parc] = case attributes[:parc]
        when 'Bleu Blanc Bouge de Saint-Michel'
          'François-Perrault'
        when "Terrain de piste et pelouse attenant à l'aréna Martin-Brodeur"
          'Saint-Léonard'
        else
          attributes[:parc]
        end

        # Sherlock has the wrong rink type
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

        # Create boroughs and rinks
        arrondissement = Arrondissement.find_by_nom_arr(nom_arr) || Arrondissement.create!(nom_arr: nom_arr)
        update_patinoires arrondissement, attributes, text
        if attributes[:patinoire]
          update_patinoires arrondissement, attributes.merge(genre: attributes[:patinoire]), text
        end

        # Check if any text has been omitted from extraction
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
      elsif line[/\A(Parc <strong>|<strong>Bassin\b)/]
        attributes = {
          parc:    text[/\A([^(,*]+)/, 1].andand.strip,
          adresse: text[/,(?: \()?((?:[^()](?! 514))+)/, 1].andand.strip,
          genre:   'PPL',
        }
        if text['*']
          attributes[:disambiguation] = 'réfrigérée'
        end          

        arrondissement = Arrondissement.find_by_nom_arr(nom_arr) || Arrondissement.create!(nom_arr: nom_arr)
        update_patinoires arrondissement, attributes, text
      end
    end
  end
end
