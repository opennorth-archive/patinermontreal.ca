# Patiner Montréal

[![Dependency Status](https://gemnasium.com/opennorth/patinermontreal.ca.png)](https://gemnasium.com/opennorth/patinermontreal.ca)

## Getting Started

    git clone git://github.com/opennorth/patinermontreal.ca.git
    cd patinermontreal.ca
    bundle
    bundle exec rake db:setup
    bundle exec rake import:donnees
    bundle exec rake import:sherlock
    bundle exec rake import:dorval
    bundle exec rake import:google
    bundle exec rake import:contacts
    bundle exec rake location:fix
    bundle exec rake location:import

It is normal to see the following output:

    "Parc de Beauséjour, 6891, boulevard Gouin Ouest (PP) (chalet)" matches no rink. Creating!
    "Parc des Hirondelles, 2574, rue Fleury Est (PPL)" matches no rink. Creating!
    "Parc Duff Court, 1830, croissant Roy (PPL)" matches no rink. Creating!
    "Parc de la Cité Jardin, boulevard Rosemont/41e Avenue (PPL et C) (chalet pas toujours ouvert)" matches no rink. Creating!
    "Parc Noël-Sud, 3025, rue Biret (PPL) " matches no rink. Creating!
    "Parc Coubertin, 4755, rue Valéry (PSE) " matches no rink. Creating!
    "Parc Guiseppe-Garibaldi, 7125, rue Liénart (PSE) " matches no rink. Creating!
    "Parc Saint-Léonard, 8255, boulevard Lacordaire (derrière l'aréna Martin-Brodeur) " matches no rink. Creating!
    "Bassin Bonsecours* (Vieux-Port) (Métro Champ-de-Mars) (chalet)" matches no rink. Creating!
    "Parc René-Goupil, 8661, 25e Avenue (PSE) (chalet) (fermée en raison de travaux pour la saison 2011-2012) " matches no rink. Creating!

## Deployment

[Create a Heroku account](http://heroku.com/signup) and setup SSH keys as described on [Getting Started with Heroku](http://devcenter.heroku.com/articles/quickstart).

    gem install heroku
    heroku create --stack cedar APP_NAME
    git push heroku master
    heroku db:push
    heroku addons:add custom_domains:basic
    heroku addons:add logging:expanded
    heroku addons:add pgbackups:auto-month
    heroku addons:add releases:basic
    heroku addons:add cron:hourly
    heroku addons:add memcache:5mb

## Bugs? Questions?

This app's main repository is on GitHub: [http://github.com/opennorth/patinermontreal.ca](http://github.com/opennorth/patinermontreal.ca), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2011 Open North Inc., released under the MIT license
