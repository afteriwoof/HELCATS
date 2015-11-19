PRO WP3_SPEED_HIST

  READ_WP3_V2,sta,stb
  ax = WHERE(sta[8,*] NE '-999')
  sta = sta[*,ax]
  bx = WHERE(stb[8,*] NE '-999')
  stb = stb[*,bx]

  imx = N_ELEMENTS(sta[0,*])
  jmx = 3
  kmx = 2
  sa = FLTARR(imx,jmx,kmx)
  FOR i=0,imx-1 DO BEGIN
     FOR j = 0,jmx-1 DO BEGIN
        FOR k = 0,kmx-1 DO BEGIN
           sa[i,j,k] = sta[8+j*8+k,i]
        ENDFOR
     ENDFOR
  ENDFOR

  imx = N_ELEMENTS(stb[0,*])
  sb = FLTARR(imx,jmx,kmx)
  FOR i=0,imx-1 DO BEGIN
     FOR j = 0,jmx-1 DO BEGIN
        FOR k = 0,kmx-1 DO BEGIN
           sb[i,j,k] = stb[8+j*8+k,i]
        ENDFOR
     ENDFOR
  ENDFOR
  PRINT,'A ',MEAN(FIX(sta[8,*]))
  PRINT,'B ',MEAN(FIX(stb[8,*]))

  smx = 2000.
  bsz = 50.
  xmx = smx/bsz
  xs = INDGEN(xmx)*bsz
  xa = FLTARR(xmx,jmx)
  xb = FLTARR(xmx,jmx)
  FOR x = 0,xmx-1 DO BEGIN
     FOR j = 0,jmx-1 DO BEGIN
        ai = WHERE((sa[*,j,0] GE x*bsz) AND (sa[*,j,0] LT (x+1)*bsz))
        IF (TOTAL(ai) NE -1) THEN xa[x,j] = N_ELEMENTS(ai)
        bi = WHERE((sb[*,j,0] GE x*bsz) AND (sb[*,j,0] LT (x+1)*bsz))
        IF (TOTAL(bi) NE -1) THEN xb[x,j] = N_ELEMENTS(bi)
     ENDFOR
  ENDFOR


  SET_PLOT,'PS'
  pdr = '~/Documents/Plots/'
  dr = 'HELCATS/catalogue/'
  fnm = 'wp3_speed_hist'
  DEVICE,XSIZE=10,YSIZE=5,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
         DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
  LOADCT,0
  !P.MULTI=[0,1,2]

  PLOT,xs,xa[*,1],/NODATA,$
       POSITION=[0.10,0.58,0.96,0.98],$
       XTICKFORMAT='(A1)',YTITLE='count',$
       XTICKINTERVAL=500,XMINOR=5.,XTICKLEN=-0.03,$
       XRANGE=[0,smx],/XSTYLE,$
       YRANGE=[0,120],CHARSIZE=1.5,CHARTHICK=1.5
  XYOUTS,1500,80,'(a) HI-1A',CHARSIZE=2,CHARTHICK=2
  WP3_SPEED_HIST_PLOT,xs,xa[*,0],bsz

  PLOT,xs,xb[*,1],/NODATA,$
       POSITION=[0.10,0.16,0.96,0.56],$
       XTITLE='speed (kms!E-1!N)',YTITLE='count',$
       XTICKINTERVAL=500,XMINOR=5.,XTICKLEN=-0.03,$
       XRANGE=[0,smx],/XSTYLE,$
       YRANGE=[0,120],CHARSIZE=1.5,CHARTHICK=1.5
  XYOUTS,1500,80,'(b) HI-1B',CHARSIZE=2,CHARTHICK=2
  WP3_SPEED_HIST_PLOT,xs,xb[*,0],bsz

  DEVICE, /CLOSE_FILE

  RETURN
END

PRO WP3_SPEED_HIST_PLOT,x,y,bin

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
  PLOTS,[x[-5],x[-5]]+0.5*bin,[y[-1],0],COLOR=0,THICK=2.0

  RETURN
END
