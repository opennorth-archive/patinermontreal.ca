# Getting Started

    git clone git://github.com/opennorth/patinermontreal.ca.git
    bundle
    bundle exec rake db:migrate
    bundle exec rake import:donnees
    bundle exec rake import:sherlock
    bundle exec rake import:dorval
    bundle exec rake import:static
    bundle exec rake location:fix
    bundle exec rake location:geocommons
    bundle exec rake location:geocode

It is normal to see the following output:

    "2" unextracted from "Parc Lasalle, 805, rue Saint-Antoine (2 PSE) (chalet)"
    "Parc de La Vérendrye, 5900, rue Drake (PPL) (chalet)" matches no rink. Creating!
    "Parc de la Cité Jardin, boulevard Rosemont/41e Avenue (PPL et C) (chalet pas toujours ouvert)" matches no rink. Creating!
    "Bassin Bonsecours* (Vieux-Port) (Métro Champ-de-Mars) (chalet)" matches no rink. Creating!
    "Parc Nicolas-Tillemont, 7833, avenue des Érables (PSE) (chalet)" matches no rink. Creating!
    "Parc Sainte-Yvette, 8950, 10e Avenue (PPL) (chalet)" matches no rink. Creating!

# Deployment

    gem install heroku
    heroku create --stack cedar APP_NAME
    git push heroku master
    heroku run rake db:migrate
    heroku run rake import:donnees
    heroku run rake import:sherlock
    heroku run rake import:dorval
    heroku run rake import:static
    heroku run rake location:fix
    heroku run rake location:geocommons
    heroku run rake location:geocode

# Misc.

* [Data sources](https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtzgYYy0ZABtdFMwSF94MjRxcW1yZ1JYVkdqM1Fzanc&single=true&gid=0&output=html)