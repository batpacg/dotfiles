#!/usr/bin/env bash

rm -rf ./target
mkdir ./target
touch ./target/realfile.conf
echo "realfile.conf from the target" > ./target/realfile.conf
mkdir -pv ./target/config/nvim/
touch ./target/config/nvim/other.lua

../sdms -s ./source -t ./target link

echo
echo "After Linking -----------------------------------------------------------"
find ./source
echo
find ./target
echo "-------------------------------------------------------------------------"

../sdms -s ./source -t ./target link

echo
echo "After Linking Again -----------------------------------------------------"
find ./source
echo
find ./target
echo "-------------------------------------------------------------------------"

../sdms -s ./source -t ./target unlink

echo
echo "After Unlinking ---------------------------------------------------------"
find ./source
echo
find ./target
echo "-------------------------------------------------------------------------"
