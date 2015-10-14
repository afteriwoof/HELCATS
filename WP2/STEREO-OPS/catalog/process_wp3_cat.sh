#!/bin/sh
#
# *** Script to genreate the various WP3 catalogue formats 
# *** The file reads from the separate STEREO A and B files
# *** combines and sorts (based on date) and then outputs
# *** versions in the original, JSON and VOTable formats.
# *** Records for which fits could not be done are excluded
# *** The reference to the file containing the time elongation
# *** "clicks" is removed as access to these files will be
# *** handled separately.
#
# *** chris.perry@stfc.ac.uk  August 2015

cat_name=HCME_WP3_V02
release="300915"

sort -k 2 STEREO-B_CME_LIST_WP3_${release}.txt STEREO-A_CME_LIST_WP3_${release}.txt | \
	grep -v " -999 " | sed 's/    HCME_[0-9ABP_]*\.dat//' > ${cat_name}.txt
awk -f wp3_ascii_to_json.awk ${cat_name}.txt > ${cat_name}.json
awk -f wp3_ascii_to_votable.awk ${cat_name}.txt > ${cat_name}.vot

