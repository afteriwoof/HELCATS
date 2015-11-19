PRO WP3_SPEED_CDF

  READ_WP3_V2,sta,stb

  ax = WHERE(sta[8,*] GT -999)
  amx = N_ELEMENTS(ax)
  sta = sta[*,ax]
  jmx = 3
  kmx = 2
  sa = FLTARR(amx,jmx,kmx)
  FOR i=0,amx-1 DO BEGIN
     FOR j = 0,jmx-1 DO BEGIN
        FOR k = 0,kmx-1 DO BEGIN
           sa[i,j,k] = sta[8+j*8+k,i]
        ENDFOR
     ENDFOR
  ENDFOR

  bx = WHERE(stb[8,*] GT -999)
  bmx = N_ELEMENTS(bx)
  stb = stb[*,bx]
  sb = FLTARR(bmx,jmx,kmx)
  FOR i=0,bmx-1 DO BEGIN
     FOR j = 0,jmx-1 DO BEGIN
        FOR k = 0,kmx-1 DO BEGIN
           sb[i,j,k] = stb[8+j*8+k,i]
        ENDFOR
     ENDFOR
  ENDFOR

  smx = 2000.
  bsz = 50.
  xmx = smx/bsz
  xs = INDGEN(xmx)*bsz
  xa = FLTARR(xmx,jmx)
  xb = FLTARR(xmx,jmx)
  FOR x = 0,xmx-1 DO BEGIN
     FOR j = 0,jmx-1 DO BEGIN
        ai = WHERE(sa[*,j,0] LT (x+1)*bsz)
        IF (TOTAL(ai) NE -1) THEN xa[x,j] = N_ELEMENTS(ai)
        bi = WHERE(sb[*,j,0] LT (x+1)*bsz)
        IF (TOTAL(bi) NE -1) THEN xb[x,j] = N_ELEMENTS(bi)
     ENDFOR
  ENDFOR


  SET_PLOT,'PS'
  pdr = '~/Documents/Plots/'
  dr = 'HELCATS/catalogue/'
  fnm = 'wp3_speed_cdf'
  DEVICE,XSIZE=10,YSIZE=5,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
         DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
  LOADCT,0
  !P.MULTI=[0,1,2]

  PLOT,xs,xa[*,0]/amx,/NODATA,$
       POSITION=[0.10,0.56,0.96,0.97],$
       XTICKFORMAT='(A1)',YTITLE='CDF',$
       XTICKINTERVAL=500,XMINOR=5.,XTICKLEN=-0.03,$
       XRANGE=[0,smx],/XSTYLE,$
       YRANGE=[0,1],CHARSIZE=1.5,CHARTHICK=1.5
  XYOUTS,1500,0.80,'(a) HI-1A',CHARSIZE=2,CHARTHICK=2
  WP3_SPEED_CDF_PLOT,xs,xa[*,0]/amx,bsz

  PLOT,xs,xb[*,0]/bmx,/NODATA,$
       POSITION=[0.10,0.11,0.96,0.52],$
       XTITLE='speed (kms!E-1!N)',YTITLE='CDF',$
       XTICKINTERVAL=500,XMINOR=5.,XTICKLEN=-0.03,$
       XRANGE=[0,smx],/XSTYLE,$
       YRANGE=[0,1],CHARSIZE=1.5,CHARTHICK=1.5
  XYOUTS,1500,0.80,'(b) HI-1B',CHARSIZE=2,CHARTHICK=2
  WP3_SPEED_CDF_PLOT,xs,xb[*,0]/bmx,bsz

  DEVICE, /CLOSE_FILE

  RETURN
END

PRO WP3_SPEED_CDF_PLOT,x,y,bin

  ymx = N_ELEMENTS(y)

  FOR i = 0,ymx-1 DO BEGIN
     ;; POLYFILL,[x[i],x[i],x[i]+bin,x[i]+bin]-0.5*bin,$
     ;;          [0,y[i],y[i],0],COLOR=155
     IF (i EQ 0) THEN BEGIN 
        PLOTS,[x[0],x[0]]-0.5*bin,[0,y[0]],THICK=2.0
     ENDIF ELSE BEGIN
        PLOTS,[x[i],x[i]]-0.5*bin,[y[i-1],y[i]],THICK=2.0
     ENDELSE
     PLOTS,[x[i],x[i]+bin]-0.5*bin,[y[i],y[i]],THICK=2.0
  ENDFOR
  ;;PLOTS,[x[-5],x[-5]]+0.5*bin,[y[-1],0],COLOR=0

  RETURN
END
