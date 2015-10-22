# *** Awk script used to transcribe the HELCATS WP3 source catalogue into
# *** JSON format.
# *** chris.perry@stfc.ac.uk August 2015

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
function trimt(s) { sub(/Z/, "", s); sub(/T/, " ", s); return s }
BEGIN {
	print "{"
	print "   \"columns\" : [ \"ID\", \"Date [UTC]\", \"SC\", \"L-N\", \"PA-N [deg]\", \"L-S\", \"PA-S [deg]\", \"Quality\" "
	print "      , \"PA-fit [deg]\""
	print "      , \"FP Speed [kms-1]\", \"FP Speed Err [kms-1]\", \"FP Phi [deg]\", \"FP Phi Err [deg]\",\"FP HEEQ Long [deg]\",  \"FP HEEQ Lat [deg]\",  \"FP Carr Long [deg]\", \"FP Launch [UTC]\"" 
	print "      , \"SSE Speed [kms-1]\", \"SSE Speed Err [kms-1]\", \"SSE Phi [deg]\", \"SSE Phi Err [deg]\", \"SSE HEEQ Long [deg]\", \"SSE HEEQ Lat [deg]\",  \"SSE Carr Long [deg]\",\"SSE Launch [UTC]\""
	print "      , \"HM Speed [kms-1]\", \"HM Speed Err [kms-1]\", \"HM Phi [deg]\", \"HM Phi Err [deg]\", \"HM HEEQ Long [deg]\", \"HM HEEQ Lat [deg]\", \"HM Carr Long [deg]\", \"HM Launch [UTC]\""
	print " ],"
	print "   \"data\" : [ "
	delim = ""
}
{
	# Check if additional columns provided
	flag_n = substr($0,51,1)
	if ( flag_n == " " ) { flag_n = "" ; off1 = 0 }
	else { off1 = 1 }

	flag_s = substr($0,58,1)
	if ( flag_s == " " ) { flag_s = "" ; off2 = off1 }
	else { off2 = off1 + 1 }

	printf( "%s [ \"%s\", \"%s\", \"%s\"", delim, $1, trimt($2), $3 )
	printf( ", \"%s\", \"%d\",  \"%s\", \"%d\"", flag_n, $(4+off1), flag_s, $(5+off2) )
	printf( ", \"%s\"\n", $(6+off2) )
	printf( ", \"%d\"\n", $(7+off2) )
	printf( ", \"%d\", \"%d\", \"%d\", \"%d\", \"%d\", \"%d\", \"%d\", \"%s\"\n", $(8+off2), $(9+off2), $(10+off2), $(11+off2), $(12+off2), $(13+off2), $(14+off2), trimt($(15+off2)) )
	printf( ", \"%d\", \"%d\", \"%d\", \"%d\", \"%d\", \"%d\", \"%d\", \"%s\"\n", $(16+off2), $(17+off2), $(18+off2), $(19+off2), $(20+off2), $(21+off2), $(22+off2), trimt($(23+off2)) )
	printf( ", \"%d\", \"%d\", \"%d\", \"%d\", \"%d\", \"%d\", \"%d\", \"%s\"\n", $(24+off2), $(25+off2), $(26+off2), $(27+off2), $(28+off2), $(29+off2), $(30+off2), trimt($(31+off2)) )
	printf( " ] \n" )
	delim = ", "
}
END {
	print "   ]"
	print "}"
}
