PRO WP3_LAT_HIST

  READ_WP3_V2,sta,stb

  ix = WHERE(sta[8,*] NE '-999')
  sta = sta[*,ix]
  imx = N_ELEMENTS(sta[0,*])
  jmx = 3
  sa = FLTARR(imx,jmx)
  FOR i=0,imx-1 DO BEGIN
     FOR j = 0,jmx-1 DO BEGIN
        sa[i,j] = sta[13+j*8,i]
     ENDFOR
  ENDFOR

  ix = WHERE(stb[8,*] NE '-999')
  stb = stb[*,ix]
  imx = N_ELEMENTS(stb[0,*])
  sb = FLTARR(imx,jmx)
  FOR i=0,imx-1 DO BEGIN
     FOR j = 0,jmx-1 DO BEGIN
        sb[i,j] = stb[13+j*8,i]
     ENDFOR
  ENDFOR

  smx = 60.
  smn = -60.
  bsz = 5.
  xmx = (smx-smn)/bsz
  xs = INDGEN(xmx)*bsz+smn
  xa = FLTARR(xmx,jmx)
  xb = FLTARR(xmx,jmx)
  FOR x = 0,xmx-1 DO BEGIN
     FOR j = 0,jmx-1 DO BEGIN
        ai = WHERE((sa[*,j] GE x*bsz+smn) AND (sa[*,j] LT (x+1)*bsz+smn))
        IF (TOTAL(ai) NE -1) THEN xa[x,j] = N_ELEMENTS(ai)
        bi = WHERE((sb[*,j] GE x*bsz+smn) AND (sb[*,j] LT (x+1)*bsz+smn))
        IF (TOTAL(bi) NE -1) THEN xb[x,j] = N_ELEMENTS(bi)
     ENDFOR
  ENDFOR


  SET_PLOT,'PS'
  pdr = '~/Documents/Plots/'
  dr = 'HELCATS/catalogue/'
  fnm = 'wp3_lat_hist'
  DEVICE,XSIZE=10,YSIZE=5,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
         DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
  LOADCT,0
  !P.MULTI=[0,1,2]

  xr = [-60,60]
  yr = [0,100]

  PLOT,xs,xa[*,1],/NODATA,$
       POSITION=[0.10,0.58,0.96,0.98],$
       XTICKFORMAT='(A1)',YTITLE='count',$
       XTICKINTERVAL=15,XMINOR=3.,XTICKLEN=-0.03,$
       XRANGE=xr,/XSTYLE,$
       YRANGE=yr,CHARSIZE=1.5,CHARTHICK=1.5
  XYOUTS,0,80,'(a) HI-1A',CHARSIZE=2,CHARTHICK=2
  WP3_LAT_HIST_PLOT,xs,xa[*,1],bsz

  PLOT,xs,xb[*,1],/NODATA,$
       POSITION=[0.10,0.16,0.96,0.56],$
       XTITLE='HEEQ latitude (degrees)',YTITLE='count',$
       XTICKINTERVAL=15,XMINOR=3.,XTICKLEN=-0.03,$
       XRANGE=xr,/XSTYLE,$
       YRANGE=yr,CHARSIZE=1.5,CHARTHICK=1.5
  XYOUTS,30,80,'(b) HI-1B',CHARSIZE=2,CHARTHICK=2
  WP3_LAT_HIST_PLOT,xs,xb[*,1],bsz

  DEVICE, /CLOSE_FILE

  RETURN
END

PRO WP3_LAT_HIST_PLOT,x,y,bin

  ymx = N_ELEMENTS(y)

  FOR i = 2,ymx-2 DO BEGIN
     ;; POLYFILL,[x[i],x[i],x[i]+bin,x[i]+bin]-0.5*bin,$
     ;;          [0,y[i],y[i],0],COLOR=155
     IF (i EQ 0) THEN BEGIN 
        PLOTS,[x[0],x[0]]-0.5*bin,[0,y[0]],THICK=2.0
     ENDIF ELSE BEGIN
        PLOTS,[x[i],x[i]]-0.5*bin,[y[i-1],y[i]],THICK=2.0
     ENDELSE
     PLOTS,[x[i],x[i]+bin]-0.5*bin,[y[i],y[i]],THICK=2.0
  ENDFOR
  PLOTS,[x[-5],x[-5]]+0.5*bin,[y[-1],0],COLOR=0,THICK=2.0
  PLOTS,[x[i],x[i]]-0.5*bin,[y[i-1],y[i]],THICK=2.0

  RETURN
END
