# coding: utf-8
task :parcs => :environment do
  require 'open-uri'
  require 'andand'

   def clean(string)
    string.gsub(/&#\d+;/) do |match|
      { '&#192;' => 'À', '&#224;' => 'à',
        '&#194;' => 'Â', '&#226;' => 'â',
        '&#196;' => 'Ä', '&#228;' => 'ä',
        '&#200;' => 'È', '&#232;' => 'è',
        '&#201;' => 'É', '&#233;' => 'é',
        '&#202;' => 'Ê', '&#234;' => 'ê',
        '&#203;' => 'Ë', '&#235;' => 'ë',
        '&#206;' => 'Î', '&#238;' => 'î',
        '&#207;' => 'Ï', '&#239;' => 'ï',
        '&#212;' => 'Ô', '&#244;' => 'ô',
        '&#140;' => 'Œ', '&#156;' => 'œ',
        '&#217;' => 'Ù', '&#249;' => 'ù',
        '&#219;' => 'Û', '&#251;' => 'û',
        '&#220;' => 'Ü', '&#252;' => 'ü',
        '&#159;' => 'Ÿ', '&#255;' => 'ÿ',
        '&#199;' => 'Ç', '&#231;' => 'ç',
        '&#8211;' => '—',
      }[match]
    end
  end

  class String
    def unabbreviate
      { '/' => ' & ',
        /^coin /u => '', # remove needless words
        /\b(\d+)e\b/u => '\1', # "8e avenue" confuses Google
        /\b(?:coin|entre|et)\b/u => '&',
        /, \d{3}.?\d{3}.?\d{4}/u => '', # remove phone numbers
        /, (?:PAT|RDP|Roxboro|Sainte-Geneviève)\b/u => '', # remove arrondissement (added later)
      }.reduce(self) do |acc, mapping|
        acc.gsub(mapping[0], mapping[1])
      end
    end

    def to_address
      self.sub(/(.+) & (.+) & (.+)/u, '\1 & \2').sub(/(.+), (.+) & (.+)/u, '\1 & \2')
    end
  end

  parser = URI::Parser.new

  arrondissement = nil
  patinoires = nil
  tel = nil

  # Le Plateau-Mont-Royal has 12, not 11, rinks
  # L'Île-Bizard–Sainte-Geneviève has 8, not 9, rinks
  # Pierrefonds-Roxboro has 14, not 25, rinks
  # Saint-Laurent has 14, not 13, rinks
  # Dollard-des-Ormeaux as 18, not 19, rinks


  # Lachine has one row as "2 PSE" (counts as two)
  # Rosemont–La Petite-Patrie has one row as "et C"
  # Saint-Laurent has 11 rows as "et rond de glace"
  # Dollard-des-Ormeaux has 11 rows as "(PSE) et (PP)"

  # 1 missing Mtl-Nord: Parc Pilon, 11135, avenue Pelletier
  # 1 missing Ville-Marie: Bassin Bonsecours (Vieux-Port) (Métro Champ-de-Mars) (chalet)

  # abri, cabane, chalet, chalet fermé, chalet pas toujours ouvert, pas de chalet, roulotte, toilettes
  # M musique
  # LA location et aiguisage
  open('http://www11.ville.montreal.qc.ca/sherlock2/servlet/template/sherlock%2CAfficherDocumentInternet.vm/nodocument/154').each do |line|
    line = clean(line)
    if matches = line.match(%r{<strong>([^<]+)</strong>.+?(\d+) patinoires})
      arrondissement = matches.first
      patinoires = matches.last.to_i
      tel = line[/\d{3}.?\d{3}.?\d{4}/]
    else
      if line[/[^>]\b(C|PP|PPL|PSE|anneau de glace|rond de glace|étang avec musique|patinoire réfrigérée du Canadien de Montréal)\b/, 1]
        text = ActionController::Base.helpers.strip_tags(line)
        parc = text[/^([^(,*]+)/u, 1].strip.to_characters.to_park
        adresse = text[/,([^(]+)/u, 1].strip.to_characters.unabbreviate
        tel = (text[/\d{3}.?\d{3}.?\d{4}/u] || tel).andand.delete('^0-9')

        if address
          geocoding = Geocoding.find_or_create_by_request("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&bounds=45.40,-73.98%7C45.71,-73.47&region=ca&address=" + parser.escape("#{parc.address.to_address}, #{parc.arrondissement}", /[^#{URI::PATTERN::UNRESERVED}]/u).gsub('%C2%96', '%E2%80%93')) # avoid INVALID_REQUEST
          if geocoding.response_object['status'] == 'OK'
            puts "TOO_MANY_RESULTS:\n#{parc.geocoding.request}\n#{parc.geocoding.results.inspect}" unless parc.geocoding.result
          else
            puts "#{parc.geocoding.response_object['status']}\n#{parc.geocoding.request}"
          end
        end
      end
    end
  end
end
