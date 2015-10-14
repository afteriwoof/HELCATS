
; Project       : HELCATS

; Name          : create_wp2_catalogue

; Purpose       : Create the WP2 catalogue output necessary for the online catalogue, by combining the text files of CME lists (by calling combine_wp2_lists.pro) and outputting the different formats (by calling process_wp2_cat.sh).

; Explanation   : The environment variable HELCATS is used to point the codes to the necessary directory. The code combine_wp2_lists.pro then reads in the 'raw' data lists (e.g. STA2007.txt; STA2008.txt; ...) and converts to observational catalogue list (e.g. STEREO-A_CME_LIST_WP2_DDMMYY.txt), and the code process_wp2_cat.sh then converts into ASCII, JSON and VOTable format.

; Use           : IDL> create_wp2_catalogue

; Inputs        : Reads in the text files of the format ST(A/B)YYYY.txt, and subsequently reads in the outputting text files of the format STEREO-[A|B]_CME_LIST_WP2.txt.

; Outputs       : Saves out a text file named STEREO-[A|B]_CME_LIST_WP2.txt and corresponding files HCME_WP2_Vnn.[txt|json|vot].

; Keywords      : test  - to run a test version 

; Calls         : none

; Category      : WP2

; Prev. Hist.   : none

; Written       : Jason P Byrne, RAL Space, October 2015.

; Revisions:
;       2015-10-14      Jason P Byrne
;       Adding comments and keyword test.




pro create_wp2_catalogue, test=test

	print, 'Running create_wp2_catalogue.pro'
	print, 'HELCATS env: ', getenv('HELCATS')

	dir = getenv('HELCATS')
	; dir = '/soft/ukssdc/share/Solar/HELCATS' 

	combine_wp2_lists, dir=dir, test=test

	if keyword_set(test) then spawn, './process_wp2_cat_test.sh' else spawn, './process_wp2_cat.sh'

end
