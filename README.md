# Getting Started

    git clone git://github.com/opennorth/patinermontreal.ca.git
    bundle
    bundle exec rake db:migrate
    bundle exec rake import:xml
    bundle exec rake import:sherlock
    bundle exec rake import:dorval
    bundle exec rake import:static
    bundle exec rake location:fix
    bundle exec rake location:geocode

# Deployment

    gem install heroku
    heroku create --stack cedar APP_NAME
    git push heroku master
    heroku run rake db:migrate
    heroku run rake import:xml
    heroku run rake import:sherlock
    heroku run rake import:dorval
    heroku run rake import:static
    heroku run rake location:fix
    heroku run rake location:geocode

# Data Sources

* [Ville de Montréal](http://donnees.ville.montreal.qc.ca/archives/fiche-donnees/patinoires)
* [Ville de Beaconsfield](www.beaconsfield.ca/FRANCAIS/culture/sports_loisirs_parcs_terrains.html)
* [Ville de Côte-Saint-Luc](http://www.cotesaintluc.org/Parks)
* [Ville de Dorval](http://www.ville.dorval.qc.ca/loisirs/fr/default.asp?contentID=808)
* [Ville de Kirkland](http://www.ville.kirkland.qc.ca/client/page2.asp?page=24&clef=7&clef2=11)
* [Ville de Pointe-Claire](http://www.ville.pointe-claire.qc.ca/library/File/Loisirs/PatinoiresExtrEtOvaleFr.pdf)
* [Ville de Sainte-Anne-de-Bellevue](http://www.ville.sainte-anne-de-bellevue.qc.ca/Loisirs,-sports-et-culture/Installations-sportives-et-recreatives-(parcs).aspx)
* [Ville de Senneville](http://www.villagesenneville.qc.ca/node/30)
* [Patinoires extérieures, Sherlock: La banque d'information municipale](http://www11.ville.montreal.qc.ca/sherlock2/servlet/template/sherlock%2CAfficherDocumentInternet.vm/nodocument/154)
