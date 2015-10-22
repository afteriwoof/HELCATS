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
	print "      <DESCRIPTION>STEREO Corongraph Graduated Cylindirical Shell CME forward modelling catalogue (WP3). </DESCRIPTION>"
	print "      <FIELD name=\"ID\" ID=\"col1\" ucd=\"meta.record\" datatype=\"char\" arraysize=\"19*\" >"
	print "        <DESCRIPTION>The unique identifer for the observed CME</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"Pre-even Date\" ID=\"col2\" ucd=\"time.epoch\" datatype=\"char\" arraysize=\"17*\" xtype=\"iso8601\" >"
	print "        <DESCRIPTION>The pre-event date associated with the event</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"Last COR2 Date\" ID=\"col2\" ucd=\"time.crossing\" datatype=\"char\" arraysize=\"17*\" xtype=\"iso8601\" >"
        print "        <DESCRIPTION>Last date when CME seen in COR2 field of view</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"GCS HEEQ Long\" ID=\"col11\" ucd=\"pos.ecliptic.long;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME HEEQ Longitude using GCS forward modelling</DESCRIPTION></FIELD>"
	print "      <FIELD name=\"GCS Carr Long\" ID=\"col12\" ucd=\"pos.ecliptic.long;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME Carrington Longitude using GCS forward modelling</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"GCS HEEQ Lat\" ID=\"col13\" ucd=\"pos.ecliptic.lat;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>CME HEEQ Latitude using GCS forward modelling</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"GCS Tilt Angle\" ID=\"col11\" ucd=\"pos.ecliptic.long;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>Tilt Angle obtained from the GCS fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"GCS Asp Ratio\" ID=\"col12\" ucd=\"pos.ecliptic.long;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>Aspect ration obtained from the GCS fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"GCS h angle\" ID=\"col13\" ucd=\"pos.ecliptic.lat;pos.heliocentric\" datatype=\"int\" width=\"4\" unitss=\"deg\"  >"
        print "        <DESCRIPTION>Half angle obtained from the GCS fitting</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"GCS Apex Speed\" ID=\"col4\" ucd=\"time.epoch\" datatype=\"char\" arraysize=\"17*\" xtype=\"iso8601\" >"
        print "        <DESCRIPTION>CME Apex Speed deteremined from GCS fitting and forward modelling</DESCRIPTION></FIELD>"
        print "      <FIELD name=\"GCS CME Mass\" ID=\"col10\" ucd=\"phys.flow;phys.veloc\" datatype=\"int\" width=\"4\" unitss=\"kmx-1\"  >"
        print "        <DESCRIPTION>CME Mass determined from GCS fitting</DESCRIPTION></FIELD>"
	print "      <DATA>"
	print "        <TABLEDATA>"
}
{
	printf( "        <TR><TD>%s</TD><TD>%s</TD><TD>%s</TD>", $1, $2, $3 )
	printf( "<TD>%d</TD><TD>%d</TD><TD>%d</TD><TD>%d</TD>", $4, $5, $6, $7 )
        printf( "<TD>%f</TD><TD>%f</TD><TD>%s</TD><TD>%s</TD>\n", $8, $9, $10, $11 )
	printf( "</TR>\n" )
}
END {
	print "        </TABLEDATA>"
	print "      </DATA>"
	print "    </TABLE>"
	print "  </RESOURCE>"
	print "</VOTABLE>"
}
