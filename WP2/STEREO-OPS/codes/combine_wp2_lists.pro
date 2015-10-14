
; Project	: HELCATS

; Name		: combine_wp2_lists

; Purpose	: Combine the text files of CME lists that are separated by year (for each spacecraft), which were manually compiled by inspecting the differenced HI images.

; Explanation	: Reads in the 'raw' data lists (e.g. STA2007.txt; STA2008.txt; ...) and converts to observational catalogue list (e.g. STEREO-A_CME_LIST_WP2_DDMMYY.txt)

; Use		: IDL> combine_wp2_lists

; Inputs	: Reads in the text files of the format ST(A/B)YYYY.txt

; Outputs	: Saves out a text file named STEREO-(A/B)_CME_LIST_WP2.txt

; Keywords	: test	- to run a test version 

; Calls		: none

; Category	: WP2

; Prev. Hist.	: Original code convert.pro written by David Barnes.

; Written	: David Barnes (edited: Jason P Byrne), RAL Space, October 2015.

; Revisions:
;	2015-10-13	Jason P Byrne
;	Formalising code updates and adding directory structure, comments & prints, and keyword test.



PRO combine_wp2_lists, dir=dir, test=test

	print, "Running code: combine_wp2_lists"
	if n_elements(dir) eq 0 then dir = getenv('HELCATS') ;'/soft/ukssdc/share/Solar/HELCATS'
	dir_codes = dir + '/codes'
	dir_input = dir + '/catalog'
	dir_output = dir + '/WP2_catalogue'

	; Create output directory if it doesn't exist
	if ~dir_exist(dir_output) then spawn, 'mkdir -p '+dir_output

	print, 'Source directory: ', dir
	print, 'Input directory: ', dir_input
	print, 'Output directory: ', dir_output

 	crafts = ['A','B']
 	years = ['2007','2008','2009','2010','2011','2012','2013','2014']
 	halos = [' No','Yes']
 	quality = ['poor','fair','good']
 	lim = [' ','<','>']
   
	FOR c = 0,1 DO BEGIN
		craft = crafts[c]
		print, "For Spacecraft ", craft
		outfile = (keyword_set(test)) ? 'STEREO-'+craft+'_CME_LIST_WP2_test.txt' : 'STEREO-'+craft+'_CME_LIST_WP2.txt'
     		outfile =  dir_output + '/' + outfile
		print, "Writing outfile: ", outfile
		OPENW,101,outfile
		FOR y = 0,N_ELEMENTS(years)-1 DO BEGIN
			year = years[y]
			i = -1
			f0 = 0
			id = 1
			cc = [-1,-1]
			infile = 'ST'+craft+year+'.txt'
			infile = dir_input + '/' + infile
			print, "Reading infile: ", infile
			OPENR,100,infile
        		WHILE ~EOF(100) DO BEGIN
				i = i+1
				line = ''
				READF,100,line
				fields = STRSPLIT(line,/EXTRACT)
				IF (i LT 2) THEN CONTINUE
				cc = [cc,fields[0]]

				;; Unique identifier
				IF (cc[i] EQ cc[i-1]) AND (f0 GT 0) THEN BEGIN
					id = id+1
				ENDIF ELSE BEGIN
					id = 1
				ENDELSE

				f1 = FIX(STRSPLIT(fields[4],'><',/EXTRACT))
				f2 = FIX(STRSPLIT(fields[6],'><',/EXTRACT))
				f0 = FIX(fields[7])
				IF (f0 EQ 0) AND (ABS(FIX(f1)-FIX(f2)) GE 20) THEN f0 = 1
         
				;; Halo ?
				IF (N_ELEMENTS(fields) GE 9) THEN BEGIN
					halo = halos[STRMATCH(fields[8],'*x*')]
				ENDIF ELSE BEGIN
					halo = halos[0]
				ENDELSE

				;; Greater/Less than ?
				l0 = lim[0]
				l1 = lim[0]
				IF (STRMATCH(fields[4],'*<*') EQ 1) THEN BEGIN
					l0 = lim[1]
					fields[4] = STRMID(fields[4],1,3)
				ENDIF
				IF (STRMATCH(fields[6],'*>*') EQ 1) THEN BEGIN
					l1 = lim[2]
					fields[6] = STRMID(fields[6],1,3)
				ENDIF
				IF ((fields[1] LE 3) AND (y EQ 0)) THEN CONTINUE
				IF (f0 EQ 0) THEN CONTINUE
				IF (c EQ 0) THEN BEGIN
					PRINTF,101,'HCME_'+craft+'__'+year+$
					 STRING(fields[1],FORMAT='(I02)')+STRING(fields[0],FORMAT='(I02)')+'_'+$
					 STRING(id,FORMAT='(I02)')+'     '+year+'-'+STRING(fields[1],FORMAT='(I02)')+'-'+$
					 STRING(fields[0],FORMAT='(I02)')+'T'+STRING(fields[2],FORMAT='(I02)')+':'+$
					 STRING(fields[3],FORMAT='(I02)')+'Z      '+craft+'    '+l0+' '+$
					 STRING(fields[4],FORMAT='(A3)')+'    '+l1+' '+STRING(fields[6],FORMAT='(A3)')+$
					 '    '+halo+'      '+STRING(quality[fields[7]]);;+'    '+STRING(fields[5],FORMAT='(A3)')
					IF (f1 GE f2) THEN PRINT,'A  ',f1,'  ',f2
				ENDIF ELSE BEGIN
					PRINTF,101,'HCME_'+craft+'__'+year+$
					 STRING(fields[1],FORMAT='(I02)')+STRING(fields[0],FORMAT='(I02)')+'_'+$
					 STRING(id,FORMAT='(I02)')+'     '+year+'-'+STRING(fields[1],FORMAT='(I02)')+'-'+$
					 STRING(fields[0],FORMAT='(I02)')+'T'+STRING(fields[2],FORMAT='(I02)')+':'+$
					 STRING(fields[3],FORMAT='(I02)')+'Z      '+craft+'    '+l1+' '+$
					 STRING(fields[6],FORMAT='(A3)')+'    '+l0+' '+STRING(fields[4],FORMAT='(A3)')+$
					 '    '+halo+'      '+STRING(quality[fields[7]]);;+'    '+STRING(fields[5],FORMAT='(A3)')
					IF (fields[4] GE fields[6]) THEN PRINT,'B  ',fields[4],'  ',fields[6],'  ',$
						year+STRING(fields[1],FORMAT='(I02)')+$
						 STRING(fields[0],FORMAT='(I02)')+'_'+$
						 STRING(id,FORMAT='(I02)')
				ENDELSE
			ENDWHILE
			; closing infile
			CLOSE,100
		ENDFOR
		; closing outfile
		CLOSE,101
		; change permissions for accessibility
		file_chmod, outfile, /a_read, /a_execute, /g_write
	ENDFOR
  	RETURN
END
