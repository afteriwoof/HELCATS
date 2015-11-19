#!/bin/sh
#
# *** Script to genreate the various WP3 KINCAT catalogue formats 
#
# *** chris.perry@stfc.ac.uk  August 2015

cat_name=KINCAT_WP3_V01

awk -f wp3k_ascii_to_json.awk ${cat_name}.txt > ${cat_name}.json
awk -f wp3k_ascii_to_votable.awk ${cat_name}.txt > ${cat_name}.vot

