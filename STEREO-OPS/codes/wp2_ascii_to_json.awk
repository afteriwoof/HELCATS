# *** Awk script used to transcribe the HELCATS WP2 source catalogue into
# *** JSON format.
# *** chris.perry@stfc.ac.uk July 2015

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
BEGIN {
	print "{"
	print "   \"columns\" : [ \"ID\", \"Date [UTC]\", \"SC\", \"L:N\", \"PA-N [deg]\", \"L:S\", \"PA-S [deg]\", \"Quality\" ],"
	print "   \"data\" : [ "
	delim = ""
}
{
	# Check if additional columns provided
	flag_n = substr($0,53,1)
	if ( flag_n == " " ) { flag_n = "" ; off1 = 0 }
	else { off1 = 1 }

	flag_s = substr($0,62,1)
	if ( flag_s == " " ) { flag_s = "" ; off2 = off1 }
	else { off2 = off1 + 1 }

	# Remove ISO8601 time "T" and "Z" from the time string
	sub(/Z/, "", $2)
	sub(/T/, " ", $2)

	printf( "%s [ \"%s\", \"%s\", \"%s\"", delim, $1, $2, $3 )
	printf( ", \"%s\", \"%d\",  \"%s\", \"%d\"", flag_n, $(4+off1), flag_s, $(5+off2) )
	printf( ", \"%s\"", $(7+off2) )
	printf( " ] \n" )
	delim = ", "
}
END {
	print "   ]"
	print "}"
}
