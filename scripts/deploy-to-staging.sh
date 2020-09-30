#!/bin/bash

set -e
set -x

# Place the site in maintenance mode.
./vendor/bin/drush @staging state:set system.maintenance_mode 1 --input-format=integer
./vendor/bin/drush @staging cr

# Backup database.
./vendor/bin/drush @staging sql-dump --result-file=auto

# Backup files.
SUFFIX=$(date +"%Y%m%d%H%M%S")
mkdir -p backups/deploy-$SUFFIX
./vendor/bin/drush rsync @staging:%files ./backups/deploy-$SUFFIX --yes

# Pull latest changes.
ssh codelab@code-lab.eu 'cd /home/codelab/domains/code-lab.eu/event-venue && git pull'

# Update dependencies.
ssh codelab@code-lab.eu 'cd /home/codelab/domains/code-lab.eu/event-venue && ./vendor/bin/composer install'

# Perform updates.
./vendor/bin/drush @staging updatedb --yes
./vendor/bin/drush @staging cr
./vendor/bin/drush @staging config:import --yes

# Disable maintenance mode.
./vendor/bin/drush @staging state:set system.maintenance_mode 0 --input-format=integer
./vendor/bin/drush @staging cr
