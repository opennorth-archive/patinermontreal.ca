# Patiner Montréal

[![Dependency Status](https://gemnasium.com/opennorth/patinermontreal.ca.png)](https://gemnasium.com/opennorth/patinermontreal.ca)

## Getting Started

    git clone git://github.com/opennorth/patinermontreal.ca.git
    cd patinermontreal.ca
    bundle
    bundle exec rake db:setup
    bundle exec rake cron
    bundle exec rake import:manual
    bundle exec rake import:location
    bundle exec rake import:contacts
    bundle exec rake import:geojson

Run `bundle exec rake db:drop` to start over.

To run the app locally, run `rails server`.

## Deployment

[Create a Heroku account](http://heroku.com/signup), [install the Heroku toolbelt](https://toolbelt.heroku.com/) and setup SSH keys as described on [Getting Started with Heroku](http://devcenter.heroku.com/articles/quickstart).

    heroku apps:create --stack cedar --addons pgbackups:auto-month memcachier scheduler:standard
    git push heroku master
    heroku config:add SECRET_TOKEN=`bundle exec rake secret`
    heroku domains:add patinermontreal.ca
    heroku domains:add www.patinermontreal.ca

To run the updates every hour, run `heroku addons:open scheduler` and add a `rake cron` job on an hourly frequency.

If you have already run the Rake tasks to build the database locally, run:

    heroku db:push

Otherwise:

    heroku run rake db:setup
    heroku run rake cron
    heroku run rake import:manual
    heroku run rake import:location
    heroku run rake import:contacts
    heroku run rake import:geojson

## Season Start & End

To reset the Heroku database at the beginning of a season, run:

    heroku pg:reset DATABASE_NAME

You can get a list of databases with:

    heroku pg:info

## Rink Maintenance

If the city changes its data such that a duplicate rink is created, you need to either:

* Delete the old rink
* Delete the new rink and change the code so that duplicate rinks are not created

### Geocode a rink

To find all non-geocoded rinks open a Rails console (`rails console` locally or `heroku run console` remotely), and run:

```ruby
Patinoire.nongeocoded
```

For prettier output, run:

```ruby
Patinoire.nongeocoded.each{|p| puts "#{p.nom} (nom_arr: #{p.arrondissement.nom_arr}, parc: #{p.parc}, genre: #{p.genre}, disambiguation: #{p.disambiguation})"};nil
```

Then, find the rink's latitude and longitude somehow (e.g. using [Google Maps](https://www.google.com/maps/mm?authuser=0&hl=en)), and enter that data into [this spreadsheet](https://docs.google.com/a/opennorth.ca/spreadsheet/ccc?key=0AtzgYYy0ZABtdEgwenRMR2MySmU5NFBDVk5wc1RQVEE#gid=2). Fill in the columns to match each rink.

### GeoJSON rinks

Rinks in **Dollard-des-Ormeaux, Laval, Vieux-Longueuil and Saint-Hubert** are now handled using static [GeoJSON](http://geojson.org/) files, instead of relying on the google [spreadsheet](https://docs.google.com/a/opennorth.ca/spreadsheet/ccc?key=0AtzgYYy0ZABtdEgwenRMR2MySmU5NFBDVk5wc1RQVEE#gid=2). The static Task parses [dollarddesormeaux.geojson](http://www.patinermontreal.ca/geojson/dollarddesormeaux.geojson), [laval.geojson](http://www.patinermontreal.ca/geojson/laval.geojson), [longueil.geojson](http://www.patinermontreal.ca/geojson/longueil.geojson) and [sainthubert.geojson](http://www.patinermontreal.ca/geojson/sainthubert.geojson) and adds the rinks to the database. Currently, Dollard-des-Ormeaux and Laval have unknown conditions `N/A`. [Vieux-Longueuil](https://www.longueuil.quebec/fr/conditions-sites-hivernaux-vieux-longueuil) and [Saint-Hubert](https://www.longueuil.quebec/fr/conditions-sites-hivernaux-saint-hubert) conditions are parsed from their respective Winter conditions HTML table.

### Delete a rink

Delete the rink from the database through a Rails console, e.g.:

```ruby
Patinoire.find(numeric_identifier).destroy
```

If the rink was added manually, delete the row from [this spreadsheet](https://docs.google.com/a/opennorth.ca/spreadsheet/ccc?key=0AtzgYYy0ZABtdEgwenRMR2MySmU5NFBDVk5wc1RQVEE#gid=0).

## Bugs? Questions?

This app's main repository is on GitHub: [http://github.com/opennorth/patinermontreal.ca](http://github.com/opennorth/patinermontreal.ca), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2011 Open North Inc., released under the MIT license
