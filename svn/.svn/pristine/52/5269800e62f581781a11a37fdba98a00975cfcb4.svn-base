# *** Awk script used to transcribe the HELCATS WP3 source catalogue into
# *** JSON format.
# *** chris.perry@stfc.ac.uk August 2015

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
function trimt(s) { sub(/Z/, "", s); sub(/T/, " ", s); return s }
BEGIN {
	print "{"
	print "   \"columns\" : [ \"ID\", \"Pre-even Date [UTC]\", \"Last COR2 Date [UTC]\" "
	print "      , \"GCD HEEQ Long [deg]\", \"GCS Carr Long [deg]\", \"GCS HEEQ Lat [deg]\" "
	print "      , \"GCS Tilt [deg]\", \"GCS Asp. Ratio\", \"GCS h angle [deg]\"" 
	print "      , \"Apex Speed [kms-1]\", \"CME Mass [kg]\" ],"
	print "   \"data\" : [ "
	delim = ""
}
{
	printf( "%s [ \"%s\", \"%s\", \"%s\"", delim, $1, trimt($2), trimt($3) )
	printf( ", \"%d\", \"%d\",  \"%d\", \"%d\"", $4, $5, $6, $7 )
	printf( ", \"%f\", \"%f\", \"%s\", \"%s\" ", $8, $9, $10, $11 )
	printf( " ] \n" )
	delim = ", "
}
END {
	print "   ]"
	print "}"
}
