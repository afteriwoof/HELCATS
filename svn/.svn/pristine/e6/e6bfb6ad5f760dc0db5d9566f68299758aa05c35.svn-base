;; Produce several background subtracted HI images

PRO LOTS_OF_IMAGES

  FOR ts0 = 0,5 DO BEGIN
     ts = 6*ts0

     ;; READ_WP2,sta,stb
     READ_WP3,sta,stb

     sc = 'A'
     ;; sc = 'B'
     stdate = [2009,06,26,00,00,00]
     ;; stdate = [2009,12,07,00,00,00]

     IF (sc EQ 'B') THEN sta = stb

     amx = N_ELEMENTS(sta[0,*])
     timea = FLTARR(5,amx)
     FOR i = 0,amx-1 DO BEGIN
        tmp = STRSPLIT(sta[1,i],' :-TZ',/EXTRACT)
        timea[*,i] = tmp
     ENDFOR
     cme = WHERE((timea[0,*] EQ stdate[0]) AND $
                 (timea[1,*] EQ stdate[1]) AND $
                 (timea[2,*] EQ stdate[2]))
     cme_id = sta[0,cme]
     IF (sc EQ 'A') THEN pa = [sta[3,cme],sta[4,cme]]
     IF (sc EQ 'B') THEN pa = [sta[4,cme],sta[3,cme]]
     stdate[3:4] = timea[3:4,cme]
     ix = 0
     IF (stdate[4] GT 10) THEN ix = 1
     tstep = FLOOR(FIX(stdate[3])*1.5)+ix

     tstep = tstep+ts
     IF (tstep GE 36) THEN BEGIN
        tstep = tstep-36
        stdate[2] = stdate[2]+1
        IF (tstep GE 36) THEN BEGIN
           tstep = tstep-36
           stdate[2] = stdate[2]+1
        ENDIF
     ENDIF

     stday=stdate(2) & stmonth=stdate(1) & styear=stdate(0)
     stdatestr=string(styear,stmonth,stday,format='(I4.4,I2.2,I2.2)')
     jul_start=DOUBLE(julday(stmonth,stday,styear,0,0,0))
     jul_now=DOUBLE(julday(stdate[1],stdate[2],stdate[0],(tstep+1)*(2./3.),10.,0.))
     jul_end=jul_start+1
     utc=create_struct('YEAR',styear,'MONTH',stmonth,'DAY',stday,$
                       'HOUR',0,'MINUTE',0,'SECOND',0,'MILLISECOND',0)
     tai_start=UTC2TAI(utc)
     tai_end=tai_start+24.0d*3600.0d

     sclow=STRLOWCASE(strtrim(sc,2))
     scupp=STRUPCASE(strtrim(sc,2))

     first=1
     file_tot=0

     hi_date = jul_start
     
     CALDAT,hi_date,inmonth,inday,inyear
     datestr=string(inyear,inmonth,inday,FORMAT='(I4.4,I2.2,I2.2)') 
     ;; PRINT,'Date:',datestr
     
     file_name='/data/ukssdc/STEREO/ares.nrl.navy.mil/lz/L2/'+$
               sclow+'/img/hi_1/'+datestr+'/*24h*br01.fts'

     PRINT,file_name
     file_list=FILE_SEARCH(file_name,count=no_files)

     HELP,file_list,tstep

     images=SCCREADFITS(file_list[tstep],headers,/NODATA,/SILENT)
     tai_all=utc2tai(headers.date_obs)
     
     this = headers.date_obs
     ft=STRSPLIT(this,'-T:',/EXTRACT)
     ftimes=ft[3]*100+ft[4]
     stimes = stdate[3]*100.+stdate[4]

     ps_file='~/Documents/Copy/'+cme_id+'_bgsub_'+STRING(ts,FORMAT='(I02)')+'h'
     pdf_file=ps_file+'.pdf'
     ps_file=ps_file+'.ps'
     OPEN_PS,ps_file,/COLOUR
     LOADCT,3
     
     imagec=SCCREADFITS(file_list[tstep],headerc,/SILENT)
     imagec=SUBTRACT_STAR_MAP(headerc,imagec)
     inew=imagec
     
     rr = GET_STEREO_LONLAT(headers.date_obs, 'A' )
     r0 = rr[0]

     launch = TAI2JULIAN(sta[23,cme])*86400.
     now = jul_now*86400.
     speed = sta[8,cme]
     phi = sta[10,cme]*!pi/180.

     r0 = 0.957*1.5E8
     vt = (speed*(now-launch))
     xr = SQRT(vt^2+r0^2-2*vt*r0*COS(phi))
     eps = ASIN(SIN(phi)*vt/xr)*180./!pi

     FOR k=0,1023 DO BEGIN
        ist=max([k-3,0])
        ien=min([k+3,1023])
        FOR j=0,1023 DO BEGIN
           jst=max([j-3,0])
           jen=min([j+3,1023])
           neighbours=imagec(ist:ien,jst:jen)
           ok=where(finite(neighbours), cnt)
           IF (cnt GT 0) THEN resistant_mean,neighbours(ok),2,tmp1,tmp2,tmp3
           IF (cnt GT 0) THEN inew(k,j)=tmp1
        ENDFOR
     ENDFOR
     inew=median(inew,5)

     wcs=FITSHEAD2WCS(headerc)
     coords=WCS_GET_COORD(wcs)
     WCS_CONV_HPC_HPR,REFORM(coords(0,*,*)),REFORM(coords(1,*,*)),pas,elongs,$
                      /zero_center,ang_units='degrees',/pos_long
     
     xstart=0
     xstop=1023
     ystart=0
     ystop=1023
     zrange=[-2.0,-0.25]	
     !P.POSITION=[0,0,1,1]
     SET_PLOT,'Z'
     !P.BACKGROUND=0
     DEVICE,SET_RESOLUTION=[1024,1024]
     PLOT,[0],[0],xstyle=5,ystyle=5,$
          xrange=[xstart,xstop+1],yrange=[ystart,ystop+1]
     
     FOR xx=xstart,xstop DO BEGIN
        FOR yy=ystart,ystop DO BEGIN
           IF (inew(xx,yy) GT 0) THEN BEGIN
              img=((FIX(255*(alog10(inew(xx,yy))-zrange(0))/$
                        (zrange(1)-zrange(0))) < 255) > 0)
              polyfill,[xx,xx,xx+1,xx+1],[yy,yy+1,yy+1,yy],col=img,/fill
           ENDIF ELSE BEGIN
              polyfill,[xx,xx,xx+1,xx+1],[yy,yy+1,yy+1,yy],col=0,/fill
           ENDELSE
        ENDFOR
     ENDFOR

     
     result=TVRD()
     SET_PLOT,'PS'
     DEVICE,XSIZE=10,YSIZE=10,/INCHES,/COLOR,BITS_PER_PIXEL=8

     xsz = !D.X_SIZE
     ysz = !D.Y_SIZE
     xb = 0.02
     yb = 0.02
     
     TV,result,xb,yb,XSIZE=1-2*xb,YSIZE=1-2*yb,/NORMAL
     LOADCT,1
     
     scl = 1.
     
     CONTOUR,pas,xstyle=5,ystyle=5,$
             POSITION=[xb,yb,1-xb,1-yb],/NORMAL,$
             xrange=[0.0,1024.0],yrange=[0.0,1024.0],$
             /noerase,c_charsize=1.0*scl,$
             level=findgen(72)*10.0,col=190,c_thick=2*scl
     
     CONTOUR,pas,xstyle=5,ystyle=5,$
             POSITION=[xb,yb,1-xb,1-yb],/NORMAL,$
             xrange=[0.0,1024.0],yrange=[0.0,1024.0],$
             /NOERASE,C_CHARSIZE=1.5*scl,CHARTHICK=1.0*scl,$
             level=pa,C_LABELS=[1,1],col=255,C_THICK=4*scl
     
     CONTOUR,elongs,xstyle=5,ystyle=5,$ 
             POSITION=[xb,yb,1-xb,1-yb],/NORMAL,$
             xrange=[0.0,1024.0],yrange=[0.0,1024.0],$
             /noerase,c_charsize=1.0*scl,$
             level=findgen(20)*5.0,col=230,c_thick=2*scl
     
     CONTOUR,elongs,xstyle=5,ystyle=5,$ 
             POSITION=[xb,yb,1-xb,1-yb],/NORMAL,$
             xrange=[0.0,1024.0],yrange=[0.0,1024.0],$
             /noerase,c_charsize=1.5*scl,CHARTHICK=1.0*scl,$
             level=eps,C_LABELS=1,col=255,c_thick=4*scl
     
     LOADCT,0
     PLOT,[0.0],[0.0],$
          xrange=[0.0,1.0],yrange=[0.0,1.0],$
          xstyle=5,ystyle=5,/NODATA,/NOERASE

     tai = tai_all
     help,tai
     tx = tai2utc(tai,/CCSDS)
     t1 = 'STEREO/HI-1'+scupp
     t2 = strmid(tx,0,10)+' '+strmid(tx,11,5)+'UT'
     xyouts,0.5,0.88,t1+' '+t2,CHARSIZE=2.0*scl,CHARTHICK=3.0*scl,ALIGN=0.5,/NORMAL,COLOR=255
     xyouts,0.5,0.10,cme_id,CHARSIZE=2.0*scl,CHARTHICK=3.0*scl,ALIGN=0.5,/NORMAL,COLOR=255
     
     CLOSE_PS

  ENDFOR
  
END
