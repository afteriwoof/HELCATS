# *** Awk script used to transcribe the HELCATS WP3 source catalogue into
# *** VOTable format.
# *** chris.perry@stfc.ac.uk August 2015

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
function xmlchar(s) { if (s=="<") return "&lt;" ; if (s==">") return "&gt;" ; return s }

BEGIN {
	print "<?xml version=\"1.0\"?>"
	print "<VOTABLE version=\"1.2\" xmlns=\"http://www.ivoa.net/xml/VOTable/v1.2\" >"
	print "  <RESOURCE name=\"HCME_WP3_V02\">"
	print "    <TABLE name=\"HCME_WP3_V02\">"
	print "      <DESCRIPTION>HELCATS STEREO CME Geometric fitting catalogue (WP3). This is a superset of the HCME_WP2_V02 CME identification catalogue</DESCRIPTION>"
	print "      <FIELD name=\"ID\" ID=\"col1\" ucd=\"meta.record\" datatype=\"char\" arraysize=\"19*\" >"
	print "        <DESCRIPTION>The unique identifer for the observed CME</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"Date\" ID=\"col2\" ucd=\"time.crossing\" datatype=\"char\" arraysize=\"17*\" xtype=\"iso8601\" >"
	print "        <DESCRIPTION>The date and time of the first observation of the CME in HI1 camera</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"SC\" ID=\"col3\" ucd=\"instr\" datatype=\"char\" arraysize=\"1*\" >"
	print "        <DESCRIPTION>The observing STEREO spacecraft, (A=Ahead or B=Behind)</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"L-N\" ID=\"col4\" ucd=\"meta.code\" datatype=\"char\" arraysize=\"1*\" >"
	print "        <DESCRIPTION>Indicator that CME extends beyond the northern edge of the field-of-view</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"PA-N\" ID=\"col5\" ucd=\"pos.posAng\" datatype=\"int\" width=\"3\" units=\"deg\" >"
	print "        <DESCRIPTION>The most northern position angle of the CME span</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"L-S\" ID=\"col6\" ucd=\"meta.code\" datatype=\"char\" arraysize=\"1*\"  >"
	print "        <DESCRIPTION>The most northern position angle of the CME span</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"PA-S\" ID=\"col7\" ucd=\"pos.posAng\" datatype=\"int\" width=\"3\" units=\"deg\" >"
	print "        <DESCRIPTION>The most southern position angle of the CME span</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"Quality\" ID=\"col8\" ucd=\"meta.note\" datatype=\"char\" arraysize=\"4*\"  >"
	print "        <DESCRIPTION>A measure of Good, Fair or Poor, that indicates the quality of the CME observation and confidence that the eruption is by definition a CME</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"PA-fit\" ID=\"col9\" ucd=\"pos.posAng\" datatype=\"int\" width=\"3\" unitss=\"deg\"  >"
	print "        <DESCRIPTION>The postion angle used in the time-elongation fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"File\" ID=\"col10\" ucd=\"meta.record\" datatype=\"char\" arraysize=\"29*\" >"
	print "        <DESCRIPTION>The file containing time-elongation data</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"FP Speed\" ID=\"col11\" ucd=\"phys.flow;phys.veloc\" datatype=\"int\" width=\"4\" unitss=\"kmx-1\"  >"
        print "        <DESCRIPTION>CME speed using on Fixed-Phi fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"FP Speed error\" ID=\"col12\" ucd=\"phys.flow;phys.veloc\" datatype=\"int\" width=\"4\" unitss=\"kmx-1\"  >"
        print "        <DESCRIPTION>uncertainty in speed using on Fixed-Phi fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"FP phi\" ID=\"col13\" ucd=\"pos.ecliptic.phi;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>Spacecraft-Sun-CME angle using on Fixed-Phi fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"FP phi error\" ID=\"col14\" ucd=\"pos.ecliptic.phi;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>Uncertainty in spacecraft-Sun-CME angle using on Fixed-Phi fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"FP HEEQ Long\" ID=\"col15\" ucd=\"pos.ecliptic.long;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME HEEQ Longitude using on Fixed-Phi fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"FP HEEQ Lat\" ID=\"col16\" ucd=\"pos.ecliptic.lat;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME HEEQ Latitude using on Fixed-Phi fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"FP Carr Long\" ID=\"col17\" ucd=\"pos.ecliptic.long;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME Carrington Longitude using Fixed-Phi fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"FP Launch\" ID=\"col4\" ucd=\"time.epoch\" datatype=\"char\" arraysize=\"17*\" xtype=\"iso8601\" >"
        print "        <DESCRIPTION>CME Launch time (r=0) using Fixed-Phi fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"SSE Speed\" ID=\"col11\" ucd=\"phys.flow;phys.veloc\" datatype=\"int\" width=\"4\" unitss=\"kmx-1\"  >"
        print "        <DESCRIPTION>CME speed using on Self-Similar Expansion fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"SSE Speed error\" ID=\"col12\" ucd=\"phys.flow;phys.veloc\" datatype=\"int\" width=\"4\" unitss=\"kmx-1\"  >"
        print "        <DESCRIPTION>uncertainty in speed using on Self-Similar Expansion fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"SSE phi\" ID=\"col13\" ucd=\"pos.ecliptic.phi;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>Spacecraft-Sun-CME angle using on Self-Similar Expansion fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"SSE phi error\" ID=\"col14\" ucd=\"pos.ecliptic.phi;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>Uncertainty in spacecraft-Sun-CME angle using on Self-Similar Expansion fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"SSE HEEQ Long\" ID=\"col15\" ucd=\"pos.ecliptic.long;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME HEEQ Longitude using on Self-Similar Expansion fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"SSE HEEQ Lat\" ID=\"col16\" ucd=\"pos.ecliptic.lat;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME HEEQ Latitude using on Self-Similar Expansion fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"SSE Carr Long\" ID=\"col17\" ucd=\"pos.ecliptic.long;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME Carrington Longitude using Self-Similar Expansion fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"SSE Launch\" ID=\"col4\" ucd=\"time.epoch\" datatype=\"char\" arraysize=\"17*\" xtype=\"iso8601\" >"
        print "        <DESCRIPTION>CME Launch time (r=0) using Self-Similar Expansion fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"HM Speed\" ID=\"col11\" ucd=\"phys.flow;phys.veloc\" datatype=\"int\" width=\"4\" unitss=\"kmx-1\"  >"
        print "        <DESCRIPTION>CME speed using on Harmonic-Mean fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"HM Speed error\" ID=\"col12\" ucd=\"phys.flow;phys.veloc\" datatype=\"int\" width=\"4\" unitss=\"kmx-1\"  >"
        print "        <DESCRIPTION>uncertainty in speed using on Harmonic-Mean fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"HM phi\" ID=\"col13\" ucd=\"pos.ecliptic.phi;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>Spacecraft-Sun-CME angle using on Harmonic-Mean fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"HM phi error\" ID=\"col14\" ucd=\"pos.ecliptic.phi;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>Uncertainty in spacecraft-Sun-CME angle using on Harmonic-Mean fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"HM HEEQ Long\" ID=\"col15\" ucd=\"pos.ecliptic.long;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME HEEQ Longitude using on Harmonic-Mean fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"HM HEEQ Lat\" ID=\"col16\" ucd=\"pos.ecliptic.lat;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME HEEQ Latitude using on Harmonic-Mean fitting</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"HM Carr Long\" ID=\"col17\" ucd=\"pos.ecliptic.long;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME Carrington Longitude using Harmonic-Mean fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"HM Launch\" ID=\"col4\" ucd=\"time.epoch\" datatype=\"char\" arraysize=\"17*\" xtype=\"iso8601\" >"
        print "        <DESCRIPTION>CME Launch time (r=0) using Harmonic-Mean fitting</DESCRIPTION></FIELD>"
	print "      <DATA>"
	print "        <TABLEDATA>"

}
{
	# Check if additional columns provided
	flag_n = substr($0,51,1)
	if ( flag_n == " " ) { flag_n = "" ; off1 = 0 }
	else { flag_n=xmlchar(flag_n) ; off1 = 1 }

	flag_s = substr($0,58,1)
	if ( flag_s == " " ) { flag_s = "" ; off2 = off1 }
	else { flag_s=xmlchar(flag_s) ; off2 = off1 + 1 }

	printf( "        <TR><TD>%s</TD><TD>%s</TD><TD>%s</TD>", $1, $2, $3 )
	printf( "<TD>%s</TD><TD>%d</TD><TD>%s</TD><TD>%d</TD>", flag_n, $(4+off1), flag_s, $(5+off2) )
	printf( "<TD>%s</TD>", $(6+off2) )
        printf( "<TD>%d</TD>\n", $(7+off2) )
        printf( "<TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%s</TD>\n", $(8+off2), $(9+off2), $(10+off2), $(11+off2), $(12+off2), $(13+off2), $(14+off2), $(15+off2) )
        printf( "<TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%s</TD>\n", $(16+off2), $(17+off2), $(18+off2), $(19+off2), $(20+off2), $(21+off2), $(22+off2), $(23+off2) )
        printf( "<TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%s</TD>\n", $(24+off2), $(25+off2), $(26+off2), $(27+off2), $(28+off2), $(29+off2), $(30+off2), $(31+off2) )
	printf( "</TR>\n" )
}
END {
	print "        </TABLEDATA>"
	print "      </DATA>"
	print "    </TABLE>"
	print "  </RESOURCE>"
	print "</VOTABLE>"
}
