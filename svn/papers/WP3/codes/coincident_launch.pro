PRO COINCIDENT_LAUNCH

  READ_WP3_V2,sta,stb
  
  r1 = 1.5E8

  this = WHERE(sta[7,*] NE '-999')
  sta = sta[*,this]
  amx = N_ELEMENTS(sta[0,*])
  ja = TAI2JULIAN(sta[1,*])
  la = TAI2JULIAN(sta[15,*])*24
  va = FIX(sta[16,*])*3.6E3
  ea = la ;;+ r1/va
  

  this = WHERE(stb[7,*] NE '-999')
  stb = stb[*,this]
  bmx = N_ELEMENTS(stb[0,*])
  jb = TAI2JULIAN(stb[1,*])
  lb = TAI2JULIAN(stb[15,*])*24
  vb = FIX(stb[16,*])*3.6E3
  eb = lb ;; + r1/vb

  ;; cmx = 1.0E2
  ;; bsz = 4.0E0
  cmx = 2.4E1
  bsz = 1.0E0
  nmx = cmx/bsz
  ;; sz = [1,2,3,6,9,12]/24.
  sz = [1,3,12]/24.
  smx = N_ELEMENTS(sz)

  v_diffa = DBLARR(smx,nmx)
  r_diff = DBLARR(smx,nmx)
  FOR i = 0,amx-1 DO BEGIN
     FOR s = 0,smx-1 DO BEGIN
        xx = WHERE(ABS(ja[i]-jb) LT sz[s])
        IF (TOTAL(xx) NE -1) THEN BEGIN
           FOR j = 0,N_ELEMENTS(xx)-1 DO BEGIN
              vi = FLOOR(ABS(ea[i]-eb[xx[j]])/bsz)
              IF (vi GE nmx) THEN CONTINUE
              v_diffa[s,vi] = v_diffa[s,vi]+1
           ENDFOR
        ENDIF
     ENDFOR
  ENDFOR

  tx = 1.0E3
  FOR s = 0,smx-1 DO BEGIN
     tmx = FIX(TOTAL(v_diffa[s,*]))*tx
     a = FLOOR(RANDOMU(s*66,tmx)*amx)
     b = FLOOR(RANDOMU(s*12,tmx)*bmx)
     FOR t = 0,tmx-1 DO BEGIN
        dv = ABS(FIX(sta[16,a[t]])-FIX(stb[16,b[t]]))/bsz
        IF (dv GE nmx) THEN CONTINUE
        r_diff[s,dv] = r_diff[s,dv]+1
     ENDFOR
  ENDFOR
  r_diff = r_diff/tx

  SET_PLOT,'PS'
  pdr = '~/Documents/Plots/'
  dr = 'HELCATS/stats/'
  fnm = 'coincident_launch'
  ;; fnm = 'coincident_arrival'
  DEVICE,XSIZE=12,YSIZE=6,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
         DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
  LOADCT,0
  !P.MULTI=[0,1,1]

  x0 = 0.60
  xd = 0.02
  x1 = x0+xd
  y0 = 0.80
  yd = 0.035
  y1 = y0+yd
  x = INDGEN(nmx)*bsz
  ymx = FLOOR(MAX(v_diffa))*1.2
  xr = [-bsz/2.,cmx]
  yr = [0.,ymx]
  ;; yr = [1.0E0,5.0E1]
  yx = WHERE(v_diffa LT yr[0])
  IF (TOTAL(yx) NE -1) THEN v_diffa[yx] = yr[0]
  labels = '+/- '+STRING(sz*24,FORMAT='(I2)')+' hrs'

  PLOT,x,v_diffa[0,*],/NODATA,$
       XTITLE='!4D!Xt (hours)',$
       XRANGE=xr,/XSTYLE,$
       YTITLE='count',$
       YRANGE=yr,/YSTYLE,$;/YLOG,$
       CHARSIZE=1.5,CHARTHICK=3.0
  FOR s = 0,smx-1 DO BEGIN
     clr = 100+(150/(smx-1))*(smx-s-1)
     CSPEED_HIST,x,v_diffa[smx-s-1,*],bsz,clr
     POLYFILL,[x0,x0,x1,x1],([y0,y1,y1,y0]-0.07*s)*1,COLOR=clr,/NORMAL
     PLOTS,[x0,x0,x1,x1,x0],([y0,y1,y1,y0,y0]-0.07*s)*1,COLOR=0,THICK=2,/NORMAL
     XYOUTS,x0+xd*1.2,(y0-0.07*s)*1,labels[smx-s-1],CHARTHICK=2,CHARSIZE=1.2,/NORMAL
  ENDFOR
  ;; FOR s = 0,smx-1 DO BEGIN
  ;;    clr = 100+(150/(smx-1))*s
  ;;    OPLOT,x,r_diff[s,*],PSYM=4,THICK=6
  ;;    OPLOT,x,r_diff[s,*],PSYM=4,THICK=6,SYMSIZE=0.4,COLOR=clr
  ;; ENDFOR

  DEVICE, /CLOSE_FILE

  RETURN
END

PRO CSPEED_HIST,x,y,bsz,clr

  ymx = N_ELEMENTS(y)

  FOR i = 0,ymx-2 DO BEGIN
     POLYFILL,[x[i],x[i],x[i]+bsz,x[i]+bsz]-bsz*0.5,$
              [0,y[i],y[i],0],COLOR=clr
     IF (i EQ 0) THEN BEGIN 
        PLOTS,[x[0],x[0]]-bsz*0.5,[0,y[0]],THICK=2
     ENDIF ELSE BEGIN
        PLOTS,[x[i],x[i]]-bsz*0.5,[y[i-1],y[i]],THICK=2
     ENDELSE
     PLOTS,[x[i],x[i]+bsz]-bsz*0.5,[y[i],y[i]],THICK=2
  ENDFOR
  PLOTS,[x[-1],x[-1]]-bsz*0.5,[y[-1],0],COLOR=0,THICK=2
  RETURN
END
