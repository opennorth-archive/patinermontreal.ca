# coding: utf-8
namespace :location do
  task :fix => :environment do
    { 'Bassin Bonsecours' => '350 rue St-Paul Est',
      'François-Perrault' => '7501, rue François-Perrault',
      'Polyvalente Saint-Henri' => 'École Saint-Henri',
      'Saint-Léonard' => '8255, boulevard Lacordaire',
      'Saint-Michel' => '5155, rue Saint-Dominique',
      'Sir-Wilfrid-Laurier' => '1115, avenue Laurier Est',
      'Terrasse Jacques-Léonard' => 'Terrasse Jacques Léonard',
    }.each do |parc,adresse|
      Patinoire.where(parc: parc, adresse: nil).each do |patinoire|
        patinoire.update_attribute :adresse, adresse
      end
    end

    # http://www.ville.ddo.qc.ca/en/googlemap_arenas.html
    { 'Coolbrooke' => '45.4985265013565,-73.79211902618408',
      'du Centenaire' => '45.486884125312414,-73.81670951843262',
      'Edward Janiszewski' => '45.48671112612774,-73.83962631225586',
      'Elmpark' => '45.4672039420346,-73.84403586387634',
      'Fairview' => '45.474690142815035,-73.82806062698364',
      'France' => '45.498906267013766,-73.82953584194183',
      'Frédérick-Wilson' => '45.490013062333524,-73.83061408996582',
      'Lake Road' => '45.48285235405571,-73.8306999206543',
      'Pinecrest' => '45.499579310747755,-73.82003545761108',
      'Spring Garden' => '45.49272065600522,-73.7858533859253',
      'Sunnybrooke' => '45.494736224553186,-73.7977409362793',
      'Terry-Fox' => '45.496120005970226,-73.82336139678955',
      'Thornhill' => '45.4788466239341,-73.8197672367096',
      'Trottier' => '45.50304968230515,-73.82055580615997',
      'Westminster' => '45.47355411001363,-73.84531259536743',
      'Westwood' => '45.48899015973809,-73.7934923171997',
    }.each do |parc,coordinates|
      arrondissement = Arrondissement.find_by_nom_arr! 'Dollard-des-Ormeaux'
      attributes[:lat], attributes[:lng] = coordinates.split(',').map(&:to_f)
      Patinoire.where(parc: parc, arrondissement_id: arrondissement.id).each do |patinoire|
        patinoire.update_attributes attributes
      end
    end
  end

  task :geocode => :environment do
    parser = URI::Parser.new
    Patinoire.nongeocoded.map(&:adresse).each do |adresse|
      param = {
        '/' => ' & ',
        /\b(\d+)e\b/ => '\1', # "8e avenue" confuses geocoder
        /\b(coin|entre|et)\b/ => '&',
        /\A(coin|derrière l'aréna,) / => '', # remove needless words
        /, (L'Île-Bizard|PAT|RDP|Roxboro|Sainte-Geneviève)\b/ => '', # remove arrondissement
      }.reduce(adresse) do |string,(from,to)|
        string.gsub(from, to)
      end

      param.sub!(/(.+)(?:,| &) (.+) & (.+)/, '\1 & \2')

      # TODO
      geocoding = Geocoding.find_or_create_by_request("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&bounds=45.40,-73.98%7C45.71,-73.47&region=ca&address=" + parser.escape("#{adresse}, #{parc.arrondissement}", /[^#{URI::PATTERN::UNRESERVED}]/u).gsub('%C2%96', '%E2%80%93')) # avoid INVALID_REQUEST
      if geocoding.response_object['status'] == 'OK'
        puts "TOO_MANY_RESULTS:\n#{parc.geocoding.request}\n#{parc.geocoding.results.inspect}" unless parc.geocoding.result
      else
        puts "#{parc.geocoding.response_object['status']}\n#{parc.geocoding.request}"
      end
    end
  end
end

