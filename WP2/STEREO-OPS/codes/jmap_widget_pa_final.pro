;----------------------------
PRO JMAP_WIDGET_PA,spacecraft,year,month,sday,num,posa=posa,dofit=dofit,small=small,$
                   rt=rt,beacon_rt=beacon_rt,beacon_img=beacon_img,stuart=stuart,$
                   kimberley=kimberley,reverse_hi=reverse_hi,zrange=zrange

zoom  = 2.0
spacecraft=STRUPCASE(STRTRIM(spacecraft,2))
syear=STRTRIM(year,2)
IF NOT KEYWORD_SET(posa) THEN posa=999.0

IF NOT KEYWORD_SET(rt) AND NOT KEYWORD_SET(beacon_rt) AND NOT $
   KEYWORD_SET(beacon_img) AND NOT KEYWORD_SET(stuart) then begin
	fname1='keogram_HI1'+spacecraft+'_widget_data_'+syear+'_pa.sav'
	fname2='keogram_HI2'+spacecraft+'_widget_data_'+syear+'_pa.sav'
ENDIF

IF KEYWORD_SET(stuart) then begin
	fname1='stuart_keogram_HI1'+spacecraft+'_widget_data_'+syear+'_pa.sav'
	fname2='stuart_keogram_HI2'+spacecraft+'_widget_data_'+syear+'_pa.sav'
ENDIF

IF KEYWORD_SET(kimberley) then begin
	fname1='kimberley_keogram_HI1'+spacecraft+'_widget_data_'+syear+'_pa.sav'
	fname2='kimberley_keogram_HI2'+spacecraft+'_widget_data_'+syear+'_pa.sav'
ENDIF

IF KEYWORD_SET(rt) then begin
	fname1='keogram_HI1'+spacecraft+'_widget_data_'+syear+'_pa_beacon.sav'
	fname2='keogram_HI2'+spacecraft+'_widget_data_'+syear+'_pa_beacon.sav'
ENDIF

IF KEYWORD_SET(beacon_rt) then begin
	fname1='keogram_HI1'+spacecraft+'_widget_data_'+syear+'_pa_beacon_rt.sav'
	fname2='keogram_HI2'+spacecraft+'_widget_data_'+syear+'_pa_beacon_rt.sav'
ENDIF

IF KEYWORD_SET(beacon_img) then begin	
	fname1='keogram_HI1'+spacecraft+'_widget_data_'+syear+'_pa_beacon_img.sav'
	fname2='keogram_HI2'+spacecraft+'_widget_data_'+syear+'_pa_beacon_img.sav'
ENDIF

fname1='/data/ukssdc/STEREO/stereo_work/jaq/KEOGRAM_DATA/'+fname1
fname2='/data/ukssdc/STEREO/stereo_work/jaq/KEOGRAM_DATA/'+fname2
IF NOT KEYWORD_SET(reverse_hi) THEN infile1=file_search(fname1,count=count1)
IF NOT KEYWORD_SET(reverse_hi) THEN infile2=file_search(fname2,count=count2)
IF     KEYWORD_SET(reverse_hi) THEN infile1=file_search(fname2,count=count1)
IF     KEYWORD_SET(reverse_hi) THEN infile2=file_search(fname1,count=count2)

IF count1 NE 1 OR count2 NE 1 THEN BEGIN
	PRINT,fname1
	PRINT,fname2	
	PRINT,'Multiple or no appropriate files found'
	RETURN
ENDIF

IF KEYWORD_SET(rt) OR KEYWORD_SET(beacon_rt) OR KEYWORD_SET(beacon_img) $
THEN bval=1 ELSE bval=0

if bval eq 0 then print,'Using science data'
if bval eq 1 then print,'Using beacon data'

outfile = '/soft/ukssdc/share/Solar/HELCATS/tracks/prog/HCME_'+spacecraft+''+$
          '__'+STRING(year,FORMAT='(I4)')+$
          STRING(month,FORMAT='(I02)')+STRING(sday,FORMAT='(I02)')+'_'+$
          STRING(num,FORMAT='(I02)')+'_PA'+STRING(posa,FORMAT='(I03)')+'.dat'

openw,10,outfile
IF KEYWORD_SET(dofit) then openw,11,outfile+'_fit'

;------------------------------------------------
PRINT,'Using file '+infile1
restore,infile1
keogram_tstart1=keogram_tstart
keogram_tstop1=keogram_tstop
keogram_ystart1=keogram_estart
keogram_ystop1=keogram_estop
keogram_title1=keogram_title
pano=WHERE(pa ge posa-1.0 and pa le posa+1.0,ctok)
IF ctok ge 1 THEN BEGIN
	pano=pano(0)
	PRINT,'Using position angle:',pa(pano)
	keogram_data1=REFORM(keogram_data(*,*,pano))
	keogram_title1=keogram_title+STRTRIM(pa(pano),2)
ENDIF ELSE BEGIN
	PRINT,'No appropriate position angle'
	Print,'List of available PAs: ',pa
	keogram_data1=REFORM(keogram_data(*,*,0))
	keogram_data1(*,*)=!values.f_nan
ENDELSE
keogram_data=0

;------------------------------------------------

PRINT,'Using file '+infile2
restore,infile2
keogram_tstart2=keogram_tstart
keogram_tstop2=keogram_tstop
keogram_ystart2=keogram_estart
keogram_ystop2=keogram_estop
keogram_title2=keogram_title
pano=WHERE(pa ge posa-1.0 and pa le posa+1.0,ctok)
IF ctok ge 1 THEN BEGIN
	pano=pano(0)
	PRINT,'Using position angle:',pa(pano)
	keogram_data2=REFORM(keogram_data(*,*,pano))
	keogram_title2=keogram_title+STRTRIM(pa(pano),2)
ENDIF ELSE BEGIN
	PRINT,'No appropriate position angle'
	Print,'List of available PAs: ',pa
	keogram_data2=REFORM(keogram_data(*,*,0))
	keogram_data2(*,*)=!values.f_nan
ENDELSE
keogram_data=0
usepa=pa(pano)

;------------------------------------------------

IF bval eq 0 then begin

FOR i=0,n_elements(keogram_tstart1)-1 DO BEGIN
	tmpdata=keogram_data1(*,i)
	result=WHERE(FINITE(tmpdata),cnt_ok)	
	IF cnt_ok gt 0 THEN BEGIN
		RESISTANT_MEAN,tmpdata(result),1,offset	
		tmpdata(result)=tmpdata(result)-offset			
	ENDIF
	keogram_data1(*,i)=MEDIAN(tmpdata,5)
ENDFOR

FOR i=0,n_elements(keogram_tstart2)-1 DO BEGIN
	tmpdata=keogram_data2(*,i)
	result=WHERE(FINITE(tmpdata),cnt_ok)
	IF cnt_ok gt 0 THEN BEGIN
		RESISTANT_MEAN,tmpdata(result),1,offset	
		tmpdata(result)=tmpdata(result)-offset			
	ENDIF
	keogram_data2(*,i)=MEDIAN(tmpdata,5)
ENDFOR

ENDIF

;------------------------------------------------

set_plot,'x'
;; WINDOW,XSIZE=2000,YSIZE=1000

keogram_title=keogram_title1+' / '+keogram_title2

base=WIDGET_BASE()

base1=WIDGET_BASE(base,/column)

lwid=WIDGET_LABEL(base1,value=keogram_title)

base2=WIDGET_BASE(base1,/row)

button=WIDGET_BUTTON(base2,value='NEW TRANSIENT',uvalue='cme')
button=WIDGET_BUTTON(base2,value='NEW TRANSIENT (refresh)',uvalue='refreshcme')
button=WIDGET_BUTTON(base2,value='FINISH',uvalue='end')

;; if not keyword_set(small) then $
;;    draw=WIDGET_DRAW(base1,XSIZE=LONG(3000)*zoom,YSIZE=LONG(800)*zoom,X_SCROLL_SIZE=1800,$
;;                     Y_SCROLL_SIZE=800,/BUTTON_EVENTS,uvalue='draw')
;; if keyword_set(small) then $
;;    draw=WIDGET_DRAW(base1,XSIZE=22500,YSIZE=600,X_SCROLL_SIZE=750,Y_SCROLL_SIZE=600,$
;;                     /BUTTON_EVENTS,uvalue='draw')

if not keyword_set(small) then $
   draw=WIDGET_DRAW(base1,XSIZE=LONG(1600)*zoom,YSIZE=LONG(800)*zoom,X_SCROLL_SIZE=1800,$
                    Y_SCROLL_SIZE=800,/BUTTON_EVENTS,uvalue='draw')
if keyword_set(small) then $
   draw=WIDGET_DRAW(base1,XSIZE=22500,YSIZE=600,X_SCROLL_SIZE=750,Y_SCROLL_SIZE=600,$
                    /BUTTON_EVENTS,uvalue='draw')

WIDGET_CONTROL,/realize,base

WIDGET_CONTROL,DRAW,GET_value=index

WSET,index

loadct,0
TVLCT,[255,255],[255,0],[255,0],!d.table_size-2
!p.color=!d.table_size-2


;; TVLCT, Reverse([[255,255],[255,0],[255,0]],1)
;; temp = !P.Color
;; !P.Color = !P.Background
;; !P.Background = temp


stday=sday
stmonth=month
styear=year

enday=sday+10
enmonth=month;+1
enyear = year
IF month EQ 12 THEN BEGIN
   enmonth = 1
   enyear = year+1
ENDIF

jul_start=julday(stmonth,stday,styear,0,0,0)
jul_end=julday(enmonth,enday,enyear,0,0,0)

utc_start=create_struct('YEAR',styear,'MONTH',stmonth,'DAY',stday,'HOUR',0,'MINUTE',0,$
                        'SECOND',0,'MILLISECOND',0)
utc_end=create_struct('YEAR',enyear,'MONTH',enmonth,'DAY',enday,'HOUR',0,'MINUTE',0,$
                      'SECOND',0,'MILLISECOND',0)

tai_start=UTC2TAI(utc_start)
tai_end=UTC2TAI(utc_end)

;; ;plot keogram
;; ;------------
erase
xrange=[tai_start,tai_end]
yrange=[4.0,74.0]

!x.ticklen=-0.04
!y.ticklen=-0.001
					
!p.position=[0.15,0.2,0.90,0.9]
dx=FLOOR((!p.position(2)-!p.position(0))*LONG(!d.x_size))
dy=FLOOR((!p.position(3)-!p.position(1))*LONG(!d.y_size))
xorig=!d.x_size*!p.position(0)
yorig=!d.y_size*!p.position(1)

img=MAKE_ARRAY(dx,dy,/BYTE,VALUE=0B)

FOR inst=1,2 DO BEGIN

	IF inst eq 1 THEN BEGIN		
		IF bval eq 0 THEN zrange=[-0.02,0.02] ELSE zrange=[-3.0,3.0]
		if keyword_set(zrange) then zrange=zrange
		xstart=LONG(dx*(keogram_tstart1-tai_start)/(tai_end-tai_start))
		xstop=LONG(dx*(keogram_tstop1-tai_start)/(tai_end-tai_start))
		ystart=FIX(dy*(keogram_ystart1-yrange(0))/(yrange(1)-yrange(0)))
		ystop=FIX(dy*(keogram_ystop1-yrange(0))/(yrange(1)-yrange(0)))
		level=((FIX(255*(keogram_data1-zrange(0))/(zrange(1)-zrange(0)))$
                        < 254) > 0)
		keogram_data=keogram_data1
	ENDIF
	
	IF inst eq 2 THEN BEGIN
		IF bval eq 0 THEN zrange=[-0.02,0.02] ELSE zrange=[-3.0,3.0]
		if keyword_set(zrange) then zrange=zrange
		xstart=LONG(dx*(keogram_tstart2-tai_start)/(tai_end-tai_start))
		xstop=LONG(dx*(keogram_tstop2-tai_start)/(tai_end-tai_start))
		ystart=FIX(dy*(keogram_ystart2-yrange(0))/(yrange(1)-yrange(0)))
		ystop=FIX(dy*(keogram_ystop2-yrange(0))/(yrange(1)-yrange(0)))	
		level=((FIX(255*(keogram_data2-zrange(0))/(zrange(1)-zrange(0)))$
                        < 254) > 0)
		keogram_data=keogram_data2
	ENDIF
	
	FOR j=0,N_ELEMENTS(ystop)-1 DO BEGIN
           IF (ystop(j) GE 0 AND ystart(j) LT dy) THEN BEGIN
              IF (ystart(j) LT 0) THEN ystart(j)=0
              IF (ystop(j) GT dy-1) THEN ystop(j)=dy-1
              FOR i=0,N_ELEMENTS(xstart)-1 DO BEGIN
                 IF (xstop(i) GE 0 AND xstart(i) LT dx) THEN BEGIN
                    IF (xstart(i) LT 0) THEN xstart(i)=0
                    IF (xstop(i) GT dx-1) THEN xstop(i)=dx-1
                    IF finite(keogram_data(j,i)) THEN img(xstart(i):xstop(i),$
                                                          ystart(j):ystop(j))=level(j,i)
                 ENDIF
              ENDFOR
           ENDIF
        ENDFOR

     ENDFOR

TV,CONGRID(img,dx,dy),xorig,yorig

			
xtitle=['Date']
ytitle=['Elongation (degrees)']
dummy=LABEL_DATE(DATE_FORMAT=['%D%M'])	
xrange=[jul_start,jul_end]

PLOT,[0],[0],xrange=xrange,yrange=yrange,xstyle=1,ystyle=1, $
     xtickformat='label_date',xtickunits='day',xminor=7,$
     xtitle=xtitle,ytitle=ytitle,/nodata,/noerase,xtickinterval=7,$
     CHARSIZE=3,CHARTHICK=2;;,COLOR=0;;,BACKGROUND=255
			
xrange1=[tai_start,tai_end]				
PLOT,[0],[0],xrange=xrange1,yrange=yrange,xstyle=5,ystyle=5,/nodata,/noerase

IF KEYWORD_SET(dofit) THEN dofit=1 ELSE dofit=0
WIDGET_CONTROL,base,SET_UVALUE={cmeno:0,flag:0,lwid:lwid}
WIDGET_CONTROL,lwid,SET_UVALUE={img:img,idim:[dx,dy],iorig:[xorig,yorig],xtitle:xtitle, $
	ytitle:ytitle,xrange:xrange,xrange1:xrange1,yrange:yrange,dofit:dofit,$
                                spacecraft:spacecraft,usepa:usepa}

XMANAGER,'plot_hi_widget',base,/no_block
	
END

;----------------------------

PRO PLOT_HI_WIDGET_EVENT,event

WIDGET_CONTROL,event.id,GET_UVALUE=value

IF value EQ 'cme' OR value eq 'refreshcme' OR value EQ 'end' THEN BEGIN

	PRINT,'New transient'
	WIDGET_CONTROL,event.top,GET_UVALUE=ustruct
	WIDGET_CONTROL,ustruct.lwid,GET_UVALUE=cmeimg
	
	IF ustruct.flag GE 1 THEN BEGIN
	
	FOR i=0,N_ELEMENTS(ustruct.xpos)-1 DO BEGIN
		print,format='(i5,3x,a25,3x,f11.5,3x,f8.2,3x,a1)',ustruct.cmeno,$
                      TAI2UTC(ustruct.xpos(i),/ccsds),ustruct.ypos(i),cmeimg.usepa,$
                      cmeimg.spacecraft
		printf,10,format='(i5,3x,a25,3x,f11.5,3x,f8.2,3x,a1)',ustruct.cmeno,$
                       TAI2UTC(ustruct.xpos(i),/ccsds),ustruct.ypos(i),cmeimg.usepa,$
                       cmeimg.spacecraft		
	ENDFOR
	
	IF cmeimg.dofit EQ 1 AND N_ELEMENTS(ustruct.xpos) GT 0 THEN BEGIN
	
	avtime=TAI2UTC((min(ustruct.xpos)+max(ustruct.xpos))/2.0,/ccsds)
	rs=(GET_STEREO_LONLAT(avtime,cmeimg.spacecraft,/degrees,system='HEE'))[0]
	re=(GET_STEREO_LONLAT(avtime,'Earth',/degrees,system='HEE'))[0]
	
	printf,11,format='(a-43,3x,i10)','Transient number:',ustruct.cmeno
	printf,11,format='(a-43,3x,a10)','STEREO spacecraft:',cmeimg.spacecraft
	printf,11,format='(a-43,3x,f10.2)','Position angle (deg):',cmeimg.usepa
	
	FOR fittype=0,2 DO BEGIN
	
		if fittype eq 0 then fitstr='Fixed Phi     '
		if fittype eq 1 then fitstr='SSE (30 deg)  '
		if fittype eq 2 then fitstr='Harm. Mean    '
	
		times=ustruct.xpos
		elongations=ustruct.ypos		
		if fittype eq 0 then ans=CME_DIRECTION_FIT_FUNC2(times,elongations,rs,re,$
                                                                 pred_launch=launch,$
                                                                 pred_arrival=arrival)
		if fittype eq 1 then ans=CME_DIRECTION_FIT_FUNC2(times,elongations,rs,re,$
                                                                 pred_launch=launch,$
                                                                 pred_arrival=arrival,$
                                                                 ssex_angle=30)
		if fittype eq 2 then ans=CME_DIRECTION_FIT_FUNC2(times,elongations,rs,re,$
                                                                 pred_launch=launch,$
                                                                 pred_arrival=arrival,$
                                                                 /harmonic_mean)
		vout=ans(0)
		verr=ans(1)
		bout=ans(2)
		berr=ans(3)
		
		IF cmeimg.usepa eq 999.0 THEN BEGIN
		
			sclon=(GET_STEREO_LONLAT(avtime,cmeimg.spacecraft,/degrees,$
                                                 system='HEE'))[1]
			IF cmeimg.spacecraft eq 'A' THEN lon=sclon-bout ELSE lon=sclon+bout
			coord1=[lon,0.0]  ;HEE
			coord2=coord1  ;HEEQ
			CONVERT_STEREO_LONLAT,spacecraft=cmeimg.spacecraft,avtime,$
                                              coord2,'HEE','HEEQ',/degrees
		
		ENDIF ELSE BEGIN
		
			beta=bout*!pi/180.0
			pa=cmeimg.usepa*!pi/180.0
			b0=(GET_STEREO_LONLAT(avtime,cmeimg.spacecraft,system='HCI'))[2]
			lat=asin(cos(b0)*sin(beta)*cos(pa)+sin(b0)*cos(beta))
			lon=atan(sin(pa)*sin(beta),cos(b0)*cos(beta)-sin(beta)*cos(pa)*$
                                 sin(b0))
			sclon=(GET_STEREO_LONLAT(avtime,cmeimg.spacecraft,/degrees,$
                                                 system='HEEQ'))[1]
			lon=sclon-lon*180.0/!pi
			coord2=[lon,lat*180.0/!pi]  ;HEEQ
			coord1=coord2  ;HEE
			CONVERT_STEREO_LONLAT,spacecraft=cmeimg.spacecraft,avtime,$
                                              coord1,'HEEQ','HEE',/degrees
						
		ENDELSE
		
		printf,11,format='(a-43,3x,f10.2,f10.2)',fitstr+$
                       'Best fit/error phi (deg):',bout,berr
		printf,11,format='(a-43,3x,f10.2,f10.2)',fitstr+$
                       'Best fit/error Vr (km/s):',vout,verr
		printf,11,format='(a-43,3x,f10.2,f10.2)',fitstr+$
                       'HEEQ lon/lat (deg):',coord2
		printf,11,format='(a-43,3x,f10.2,f10.2)',fitstr+$
                       'HEE lon/lat (deg):',coord1
		printf,11,format='(a-43,a23)',fitstr+'Launch time estimate:',launch
		printf,11,format='(a-43,a23)',fitstr+'1 AU arrival time estimate:',arrival
		
		;ANGLE CHECK
		scvals=GET_STEREO_LONLAT(avtime,cmeimg.spacecraft,/degrees,system='HEEQ')
		l1=scvals(2)*!pi/180.0   		;sc lat
		l2=coord2(1)*!pi/180.0   		;transient lat
		dL=(scvals(1)-coord2(0))*!pi/180.0 	;lon diff
		d=acos(cos(l1)*cos(l2)*cos(dL)+sin(l1)*sin(l2))*180.0/!pi
		print,d
		
		scvals=GET_STEREO_LONLAT(avtime,cmeimg.spacecraft,/degrees,system='HEE')
		l1=scvals(2)*!pi/180.0   		;sc lat
		l2=coord1(1)*!pi/180.0   		;transient lat
		dL=(scvals(1)-coord1(0))*!pi/180.0 	;lon diff
		d=acos(cos(l1)*cos(l2)*cos(dL)+sin(l1)*sin(l2))*180.0/!pi
		print,d		
		
             ENDFOR
	
		printf,11,'  '		
		
	ENDIF
	ENDIF
	
	ustruct.cmeno=ustruct.cmeno+1	
	ustruct.flag=0		
	
	WIDGET_CONTROL,event.top,SET_UVALUE=ustruct
	
 	IF value EQ 'end' THEN BEGIN
		PRINT,'Finished!'
		close,/all
		WIDGET_CONTROL,event.top,/destroy
	ENDIF
	
 	IF value EQ 'refreshcme' THEN BEGIN
		polyfill,[0.0,0.0,1.0,1.0,0.0],	[0.0,1.0,1.0,0.0,0.0],/norm,col=0
		
		TV,CONGRID(cmeimg.img,cmeimg.idim[0],cmeimg.idim[1]),cmeimg.iorig[0],$
                   cmeimg.iorig[1]
				
		PLOT,[0],[0],xrange=cmeimg.xrange,yrange=cmeimg.yrange,xstyle=1,ystyle=1,$
                     xtickformat='label_date',xtickunits='day',xminor=7,$
                     xtitle=cmeimg.xtitle,ytitle=cmeimg.ytitle,/nodata,/noerase,$
                     xtickinterval=7
							
		PLOT,[0],[0],xrange=cmeimg.xrange1,yrange=cmeimg.yrange,xstyle=5,$
                     ystyle=5,/nodata,/noerase
	ENDIF	

ENDIF ELSE IF event.type EQ 0 THEN BEGIN

	dx=(!p.position(2)-!p.position(0))*!d.x_size
	dy=(!p.position(3)-!p.position(1))*!d.y_size
	
	xorig=!p.position(0)*!d.x_size
	yorig=!p.position(1)*!d.y_size
		 
	xpos=(!x.crange(1)-!x.crange(0))*(event.x-xorig)/dx+!x.crange(0)
	ypos=(!y.crange(1)-!y.crange(0))*(event.y-yorig)/dy+!y.crange(0)
	
	tmp=findgen(40)*(!pi*2.0/39.0)
	usersym,0.7*cos(tmp),0.7*sin(tmp),/fill
	OPLOT,[xpos],[ypos],COLOR=255,psym=8
	
	WIDGET_CONTROL,event.top,GET_UVALUE=ustruct
	
	IF ustruct.flag EQ 0 THEN BEGIN
		ustruct={cmeno:ustruct.cmeno,flag:1,xpos:[xpos],ypos:[ypos],$
                         lwid:ustruct.lwid}
	ENDIF ELSE BEGIN
		ustruct={cmeno:ustruct.cmeno,flag:1,xpos:[ustruct.xpos,xpos],$
                         ypos:[ustruct.ypos,ypos],lwid:ustruct.lwid}
	ENDELSE
	
	WIDGET_CONTROL,event.top,SET_UVALUE=ustruct
		
ENDIF

END
