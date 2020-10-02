#!/bin/bash

# Get the latest code from the github repository.
git pull

# Install any new or updated dependencies.
./vendor/bin/composer install

# Regenerate the configuration files since they might have changed.
./vendor/bin/robo dev:setup

# Copy the database.
./vendor/bin/drush sql:sync @staging @self --yes

# Copy the files and images.
./vendor/bin/drush rsync @staging:%files @self:%files --yes

# Perform updates.
./vendor/bin/drush updatedb --yes --no-post-updates
./vendor/bin/drush config:import --yes
./vendor/bin/drush updatedb --yes

# Clear the cache.
./vendor/bin/drush cr

# Index content in the search engine.
./vendor/bin/drush sapi-i
