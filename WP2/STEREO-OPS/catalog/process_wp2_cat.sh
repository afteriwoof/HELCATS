#!/bin/sh
#
# *** Script to genreate the various WP2 catalogue formats 
# *** The file reads from the separate STEREO A and B files
# *** combines and sorts (based on date) and then outputs
# *** versions in the original, JSON and VOTable formats.
#
# *** chris.perry@stfc.ac.uk  July 2015

cat_name=HCME_WP2_V02
release="220715"

sort -k 2 STEREO-B_CME_LIST_WP2_${release}.txt STEREO-A_CME_LIST_WP2_${release}.txt > ${cat_name}.tmp
awk -f wp2_ascii_to_json.awk ${cat_name}.tmp > ${cat_name}.json
awk -f wp2_ascii_to_votable.awk ${cat_name}.tmp > ${cat_name}.vot
sed -e 's/    Yes//' -e 's/     No//' < ${cat_name}.tmp > ${cat_name}.txt

rm -f ${cat_name}.tmp
