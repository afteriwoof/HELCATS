; PLOT_DIFF_IMAGES
;
;	To make the difference images of the SECCHI/HI images:
;
;
; INPUTS:
;	sc		the spacecraft name as a string, e.g. 'Ahead'
;	indate		the input date.
;			Date format can be standard string format,
;			e.g. 2008-02-01, 08/02/01, 01-Feb-08, 
;			or integer format as [day,month,year].
;
; OUTPUTS:
;	outdata		to output the data of the smoothed differenced images.
;	
;
; KEYWORDS:
;	outdir		specify the output directory.
;		 	Output directory can be set to somewhere in HELCATS, e.g. /soft/ukssdc/share/Solar/HELCATS/
;	tog		to toggle out the postscript files otherwise display.
;	overplot	needs to be set if tog isn't set, so as to overplot the contours on the window device.
;	single_im	to run code on a single image (taking just the prior image for the difference).
;
;
; Edited:
;	2014-11-25	Jason Byrne 
;			adapted from Jackie Davie's original plot_diff_images.pro code.
;	2014-12-02	to provide option to take output data under the outdata keyword.
;	2014-12-09	to include keyword single_im.
;
;
;----------------------------

; stick in startdate and enddate

PRO plot_diff_images, sc, startdate, enddate, outdir=outdir, tog=tog, overplot=overplot, outdata=outdata, single_im=single_im

; convert startdate to indate for the input date only
indate = anytim(startdate, /ccsds, /date_only)

if keyword_set(single_im) then enddate=startdate

if n_elements(outdir) eq 0 then outdir='.' & print, 'Output directory is: ', outdir

; Check if date is string or number:
case size(indate,/tn) of
 'STRING':	begin
		indatestr = strjoin(strsplit(anytim(startdate,/ccsds,/date_only),'-',/extract))
		intimestr = strjoin(strsplit(anytim(startdate,/ccsds,/time_only),':',/extract))
		styear=fix(strmid(indatestr,0,4)) & stmonth=fix(strmid(indatestr,4,2)) & stday=fix(strmid(indatestr,6,2))
		sthour=fix(strmid(intimestr,0,2)) & stmin = fix(strmid(intimestr,2,2)) & stsec=fix(strmid(intimestr,4,2))
		end
	else:	begin
		stday=indate(0) & stmonth=indate(1) & styear=indate(2)
		indatestr=string(styear,stmonth,stday,format='(I4.4,I2.2,I2.2)')
		end
endcase

; if no enddate is specified set it to end of the input startdate
if n_elements(enddate) eq 0 then begin
	enddate=indate+'T23:59:59' 
	endyear=styear & endmonth=stmonth & endday=stday
	endhour=sthour & endmin=stmin & endsec=stsec
endif else begin
	enddatestr = strjoin(strsplit(anytim(enddate,/ccsds,/date_only),'-',/extract))
	endtimestr = strjoin(strsplit(anytim(enddate,/ccsds,/time_only),':',/extract))
	endyear=fix(strmid(enddatestr,0,4)) & endmonth=fix(strmid(enddatestr,4,2)) & endday=fix(strmid(enddatestr,6,2))
	endhour=fix(strmid(endtimestr,0,2)) & endmin = fix(strmid(endtimestr,2,2)) & endsec=fix(strmid(endtimestr,4,2))
endelse

sclow=strlowcase(strtrim(sc,2))
sclow = strmid(sclow,0,1)
scupp=strupcase(strtrim(sc,2))
scupp = strmid(scupp,0,1)

jul_start=julday(stmonth,stday,styear,sthour,stmin,stsec)
jul_end = julday(endmonth,endday,endyear,endhour,endmin,endsec)

stutc=create_struct('YEAR',styear,'MONTH',stmonth,'DAY',stday,'HOUR',sthour,'MINUTE',stmin,'SECOND',stsec,'MILLISECOND',0)
endutc=create_struct('YEAR',endyear,'MONTH',endmonth,'DAY',endday,'HOUR',endhour,'MINUTE',endmin,'SECOND',endsec,'MILLISECOND',0)
tai_start=UTC2TAI(stutc)
;tai_end=tai_start+60*60*24L
tai_end = UTC2TAI(endutc)

;----------------------------------------------------------------------------------------------

;read in dataset
;---------------
first=1
file_tot=0

days = anytim2cal(timegrid(startdate,enddate,/days),form=11,/da)
for hi_date = jul_start-1,jul_end do begin
;for i=0,n_elements(days)-1 do begin
	;datestr = strjoin(strsplit(days[i],'/',/extract))
	caldat,hi_date,inmonth,inday,inyear,inhour,inmin,insec
	datestr=string(inyear,inmonth,inday,format='(I4.4,I2.2,I2.2)') 

	print, 'Reading files from:'
	print, '/data/ukssdc/STEREO/ares.nrl.navy.mil/lz/L2_1_25/'+sclow+'/img/hi_1/'+datestr	
	file_name='/data/ukssdc/STEREO/ares.nrl.navy.mil/lz/L2_1_25/'+sclow+'/img/hi_1/'+datestr+'/*.fts'
	file_list=FILE_SEARCH(file_name,count=no_files)
	IF no_files GT 0 AND first EQ 1 THEN BEGIN
		files_all=file_list
		first=0
	ENDIF ELSE IF no_files GT 0 THEN BEGIN
		files_all=[files_all,file_list]
	ENDIF ELSE IF no_files EQ 0 THEN print, 'No files.'

endfor

print, 'files_all: ' & print, files_all

; Take only the files within the time window
file_times = strmid(file_basename(files_all),0,15)
file_times = strmid(file_times,0,4)+'/'+strmid(file_times,4,2)+'/'+strmid(file_times,6,2)+'T'+strmid(file_times,9,2)+':'+strmid(file_times,11,2)+':'+strmid(file_times,13,2)
ind = setintersection(where(anytim(file_times) ge anytim(startdate)), where(anytim(file_times) le anytim(enddate)))
; take the previous image for the running difference frame
if ind[0] gt 0 then ind=[ind[0]-1,ind]
; new files_all is then
files_all = files_all[ind]

IF N_ELEMENTS(files_all) GT 0 THEN BEGIN
	outdata=SCCREADFITS(files_all,headers,/SILENT)
	ok=where(headers.naxis1 EQ 1024 and headers.naxis2 EQ 1024 and headers.doorstat NE 0, no_files)	
	files_all=files_all(ok)
	tai_all=utc2tai(headers(ok).date_obs)
	tai_end = tai_all[n_elements(tai_all)-1]
ENDIF

;process data set
;----------------	

IF datestr eq indatestr THEN BEGIN
IF N_ELEMENTS(files_all) GT 0 THEN BEGIN

images=SCCREADFITS(files_all,headers,/NODATA,/SILENT)
ok=where(headers.naxis1 EQ 1024 and headers.naxis2 EQ 1024 and headers.doorstat NE 0, no_files)	
files_all=files_all(ok)
tai_all=utc2tai(headers(ok).date_obs)

zrange=[-0.0415,0.0415]

xstart=1 & xstop=1023 & ystart=1 & ystop=1023
first=1
avcadence=40.0
mingap=-0.75*avcadence
maxgap=-3.10*avcadence

FOR fno=0,N_ELEMENTS(files_all)-1 DO BEGIN

	tai=tai_all(fno)
	taidiff=(tai_all-tai)/60.0
	tmp1=where(taidiff GE maxgap AND taidiff LE mingap,ct)
	
	IF ct gt 0 and tai GE tai_start AND tai LE tai_end THEN BEGIN
	
		tmp2=ABS(taidiff(tmp1)+avcadence)
		ok2=where(tmp2 eq min(tmp2))
		ok3=tmp1(ok2(0))
		
		if first eq 1 then begin
			if keyword_set(tog) then begin
				ps_dir = outdir+'/'+strmid(indatestr,0,4)+'/'+strmid(indatestr,4,2)+'/'+strmid(indatestr,6,2)
				print, 'Making directory: ', ps_dir		
				spawn, 'mkdir -p '+ps_dir
				ps_file = ps_dir+'/HI1'+scupp+'_'+datestr+'_diff.ps'
				print,'writing to: ',ps_file
				open_ps,ps_file,/colour
			endif	
			loadct,0
			first=0
		endif
		
		imagec=SCCREADFITS(files_all(fno),headerc,/SILENT)	
		imagep=SCCREADFITS(files_all(ok3),headerp,/SILENT)
		
		print,'Current image: ',file_basename(files_all(fno))
		print,'Previous image: ',file_basename(files_all(ok3))
		
		moved=hi_align_image(headerp,imagep,headerc,/radec,cubic=-0.5)
		diff=imagec-moved
			
		diff_new=diff
		FOR k=0,1023 DO BEGIN
			ist=max([k-4,0])
			ien=min([k+4,1023])					
			FOR j=0,1023 DO BEGIN
				jst=max([j-4,0])
				jen=min([j+4,1023])
				neighbours=diff(ist:ien,jst:jen)
				ok=where(finite(neighbours), cnt)
				if cnt gt 0 then resistant_mean,neighbours(ok),2,tmp1,tmp2,tmp3
				if cnt gt 0 then diff_new(k,j)=tmp1
			ENDFOR
		ENDFOR								
		diff=median(diff_new,5)	
		ok=where(finite(diff),cnt)
		if cnt gt 0 then begin
			resistant_mean,diff(ok),2,tmp1,tmp2,tmp3				
			diff=diff-tmp1
		endif		
	
		diff=diff/(-1.0*taidiff(ok3)/avcadence)
		print,'taidiff(ok3)/40.0 : ', taidiff(ok3)/40.0
		img=((FIX(255*(diff-zrange(0))/(zrange(1)-zrange(0))) < 255) > 0)

		if keyword_set(single_im) then outdata = img else outdata[*,*,fno] = img

		; Write out the FITS of the differenced images
		if keyword_set(tog) then begin
			fits_dir = outdir+'/'+strmid(indatestr,0,4)+'/'+strmid(indatestr,4,2)+'/'+strmid(indatestr,6,2)+'/fits'
			spawn, 'mkdir -p '+fits_dir
			sccwritefits, fits_dir+'/'+strmid(headerc.filename,0,strlen(headerc.filename)-4)+'_diff.fts', img, headerc
		endif
				
		tx=tai2utc(tai,/ccsds)
		tit1='HI-1'+scupp		
		tit2=strmid(tx,0,10)+' '+strmid(tx,11,5)+'UT'
	
		!p.position=[0,0,1,1] & set_plot,'Z' & !p.background=255 & device,set_resolution=[512,512]
			
		plot,[0],[0],xstyle=5,ystyle=5,xrange=[xstart,xstop+1],yrange=[ystart,ystop+1]														
		FOR xx=xstart,xstop do begin
		FOR yy=ystart,ystop do begin
			polyfill,[xx,xx,xx+1,xx+1],[yy,yy+1,yy+1,yy],col=img(xx,yy),/fill
		ENDFOR
		ENDFOR	
			
		result=TVRD()
		
		if keyword_set(tog) then begin
			set_plot,'PS'
			voff=0.15	
			!p.position=[0.08,(0.04+voff)*1.0*!D.X_SIZE/!D.Y_SIZE,0.92,(0.88+voff)*1.0*!D.X_SIZE/!D.Y_SIZE]	
			xorig=!d.x_size*!p.position(0)
			yorig=!d.y_size*!p.position(1)	
		
			TV,result,xorig,yorig,xsize=(!p.position[2]-!p.position[0])*!d.x_size, $
		   		ysize=(!p.position[3]-!p.position[1])*!d.y_size 
		endif else begin
			set_plot,'X'
			window, xs=(size(result))[1], ys=(size(result))[2]
		endelse
		plot,[0],[0],xrange=[0.0,1.0],yrange=[0.0,1.0],/noerase,/nodata,xstyle=5,ystyle=5,charsize=1.5
		xyouts,0.5,1.25,tit1,charsize=2.0,charthick=5,col=0,align=0.5
		xyouts,0.5,1.15,tit2,charsize=1.5,charthick=5,col=0,align=0.5
		
		wcs=FITSHEAD2WCS(headerc)
		coords=WCS_GET_COORD(wcs)
		WCS_CONV_HPC_HPR,REFORM(coords(0,*,*)),REFORM(coords(1,*,*)), $
			pas,elongs,/zero_center,ang_units='degrees',/pos_long
		
		if ~keyword_set(tog) then plot_image, img, xstyle=1+4, ystyle=1+4
		
		loadct,39
		contour,pas,xstyle=5,ystyle=5,xrange=[0.0,1024.0],yrange=[0.0,1024.0],$
			/noerase,c_charsize=0.65,level=findgen(72)*5.0,col=100,c_thick=3, overplot=overplot
		labs=make_array(20,/int,value=0)
		contour,elongs,xstyle=5,ystyle=5,xrange=[0.0,1024.0],yrange=[0.0,1024.0],$
			/noerase,c_charsize=0.65,level=findgen(20)*2.0,col=200,c_thick=3, overplot=overplot
					
		pos_earth=GET_STEREO_LONLAT(headerc.date_avg,headerc.obsrvtry,system='hpc',target='earth',/degrees)
		WCS_CONV_HPC_HPR,REFORM(pos_earth(1)),REFORM(pos_earth(2)), $
			paearth,elongearth,/zero_center,ang_units='degrees',/pos_long
		
		contour,pas,xstyle=5,ystyle=5,xrange=[0.0,1024.0],yrange=[0.0,1024.0],$
			/noerase,c_charsize=0.65,level=[paearth],col=250,c_label=[0],c_thick=3, overplot=overplot
			
		plot,[0],[0],xrange=[0.0,1.0],yrange=[0.0,1.0],/noerase,/nodata,xstyle=5,ystyle=5,charsize=1.5	
		xyouts,0.0,-0.055,'Earth PA: '+string(paearth,format='(F7.2)')+'!uo!n',charsize=1.0,charthick=5,col=250
		xyouts,0.0,-0.085,'Current Image: '+file_basename(files_all(fno)),charsize=0.5,charthick=5,col=250
		xyouts,0.0,-0.105,'Previous Image: '+file_basename(files_all(ok3)),charsize=0.5,charthick=5,col=250
		
		res=GET_STEREO_LONLAT(headerc.date_obs,scupp,/degrees,system='HEE')
		xyouts,0.5,1.065,'Spacecraft Longitude (HEE): '+string(res(1),format='(F7.2)')+'!uo!n',charsize=1.0,charthick=5,align=0.5

		loadct,0

		erase
	
	ENDIF

	print, ' '
ENDFOR

ENDIF

; Remove the first image of outdata which is the previous image to the initial one being differenced
outdata = outdata[*,*,1:*]

if keyword_set(tog) then begin

	close_ps

	if first eq 0 then begin
	
		ps_file = ps_dir+'/HI1'+scupp+'_'+datestr+'_diff.ps'
		pdf_file = ps_dir+'/HI1'+scupp+'_'+datestr+'_diff.pdf'
			
		cmmnd1='ps2pdf '+ps_file+' '+pdf_file
		cmmnd2='rm -f '+ps_file
		print,cmmnd1
		print,cmmnd2
		
		spawn,cmmnd1
		spawn,cmmnd2
	endif
endif

ENDIF

END

;----------------------------
