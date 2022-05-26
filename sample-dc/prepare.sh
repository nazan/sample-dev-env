#!/usr/bin/env bash

# First time routine. Run as follows.
# > cd root-of-project
# > make kot-prepare

composer install
php artisan key:generate

php artisan cache:clear
php artisan migrate

# Seeders yet to come.

echo "Initial bootstrap complete."