#!/bin/bash

set -e
set -x

# Get the latest code from the github repository.
git pull

# Install any new or updated dependencies.
composer install
cd ./web/profiles/contrib/droopler/themes/custom/droopler_theme
npm install
gulp compile
cd -
cd ./web/themes/custom/droopler_subtheme
npm install
gulp compile
cd -

# Regenerate the configuration files since they might have changed.
lando robo dev:setup

# Copy the database.
lando drush sql:sync @staging @self --yes

# Copy the files and images.
lando drush rsync @staging:%files @self:%files --yes

# Perform updates.
lando drush updatedb --yes --no-post-updates
lando drush config:import --yes
lando drush updatedb --yes

# Clear the cache.
lando drush cr
