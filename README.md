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

Run `bundle exec rake db:drop` to start over.

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

To end the season and display the sign-up page, run:

    heroku config:add MAINTENANCE=on

To turn off the sign-up page at the beginning of a season, run:

    heroku config:remove MAINTENANCE

To reset the Heroku database at the beginning of a season, run:

    heroku pg:reset DATABASE_NAME

You can get a list of databases with:

    heroku pg:info

## Bugs? Questions?

This app's main repository is on GitHub: [http://github.com/opennorth/patinermontreal.ca](http://github.com/opennorth/patinermontreal.ca), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2011 Open North Inc., released under the MIT license
