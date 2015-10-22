# *** Awk script used to transcribe the HELCATS WP2 source catalogue into
# *** VOTable format.
# *** chris.perry@stfc.ac.uk July 2015

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
function xmlchar(s) { if (s=="<") return "&lt;" ; if (s==">") return "&gt;" ; return s }

BEGIN {
	print "<?xml version=\"1.0\"?>"
	print "<VOTABLE version=\"1.2\" xmlns=\"http://www.ivoa.net/xml/VOTable/v1.2\" >"
	print "  <RESOURCE name=\"HCME_WP2_V02\">"
	print "    <TABLE name=\"HCME_WP2_V02\">"
	print "      <DESCRIPTION>HELCATS STEREO Manual CME Detection Catalogue (WP2)</DESCRIPTION>"
	print "      <FIELD name=\"ID\" ID=\"col1\" ucd=\"meta.record\" datatype=\"char\" arraysize=\"19*\" >"
	print "        <DESCRIPTION>The unique identifer for the observed CME</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"Date\" ID=\"col2\" ucd=\"time.crossing\" datatype=\"char\" arraysize=\"17*\" xtype=\"iso8601\" >"
	print "        <DESCRIPTION>The date and time of the first observation of the CME in HI1 camera</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"SC\" ID=\"col3\" ucd=\"instr\" datatype=\"char\" arraysize=\"1*\" >"
	print "        <DESCRIPTION>The observing STEREO spacecraft, (A=Ahead or B=Behind)</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"L:N\" ID=\"col4\" ucd=\"meta.code\" datatype=\"char\" arraysize=\"1*\" >"
	print "        <DESCRIPTION>Indicator that CME extends beyond the northern edge of the field-of-view</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"PA-N\" ID=\"col5\" ucd=\"pos.posAng\" datatype=\"int\" width=\"3\" units=\"deg\" >"
	print "        <DESCRIPTION>The most northern position angle of the CME span</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"L:S\" ID=\"col6\" ucd=\"meta.code\" datatype=\"char\" arraysize=\"1*\"  >"
	print "        <DESCRIPTION>The most northern position angle of the CME span</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"PA-S\" ID=\"col7\" ucd=\"pos.posAng\" datatype=\"int\" width=\"3\" units=\"deg\" >"
	print "        <DESCRIPTION>The most southern position angle of the CME span</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"Quality\" ID=\"col8\" ucd=\"meta.note\" datatype=\"char\" arraysize=\"4*\"  >"
	print "        <DESCRIPTION>A measure of Good, Fair or Poor, that indicates the quality of the CME observation and confidence that the eruption is by definition a CME</DESCRIPTION></FIELD>"
	print "      <DATA>"
	print "        <TABLEDATA>"
}
{
	# Check if additional columns provided
	flag_n = substr($0,53,1)
	if ( flag_n == " " ) { flag_n = "" ; off1 = 0 }
	else { flag_n=xmlchar(flag_n) ; off1 = 1 }

	flag_s = substr($0,62,1)
	if ( flag_s == " " ) { flag_s = "" ; off2 = off1 }
	else { flag_s=xmlchar(flag_s) ; off2 = off1 + 1 }

	printf( "        <TR><TD>%s</TD><TD>%s</TD><TD>%s</TD>", $1, $2, $3 )
	printf( "<TD>%s</TD><TD>%d</TD><TD>%s</TD><TD>%d</TD>", flag_n, $(4+off1), flag_s, $(5+off2) )
	printf( "<TD>%s</TD>", $(7+off2) )
	printf( "</TR>\n" )
}
END {
	print "        </TABLEDATA>"
	print "      </DATA>"
	print "    </TABLE>"
	print "  </RESOURCE>"
	print "</VOTABLE>"
}
