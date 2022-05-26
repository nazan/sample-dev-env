#!/usr/bin/env bash

mkdir -p bootstrap/cache
find ./bootstrap/cache ! -name .gitignore | xargs chmod 777

mkdir -p storage
find ./storage ! -name .gitignore | xargs chmod 777