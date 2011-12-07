# coding: utf-8
task :cron => :environment do
  Nokogiri::XML(RestClient.get('http://depot.ville.montreal.qc.ca/patinoires/data.xml')).css('patinoire').each do |node|
    arrondissement = Arrondissement.find_or_initialize_by_nom_arr node.at_css('nom_arr').text.gsub(' - ', '—')
    arrondissement.cle = node.at_css('cle').text
    arrondissement.date_maj = Time.parse node.at_css('date_maj').text
    arrondissement.save!

    patinoire = Patinoire.find_or_initialize_by_nom node.at_css('nom').text
    %w(ouvert deblaye arrose resurface condition).each do |attribute|
      patinoire[attribute] = node.at_css(attribute).text
    end
    patinoire.arrondissement = arrondissement
    patinoire.save!
  end
end
