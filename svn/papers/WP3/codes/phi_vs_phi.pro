PRO PHI_VS_PHI,in1,in2

  READ_WP3_V2,sta,stb
  fits = ['FP','SSE','HM']

  this = WHERE(sta[7,*] NE '-999')
  sta = sta[*,this]
  amx = N_ELEMENTS(sta[0,*])
  phi_1a = sta[10+8*in1,*]
  phi_2a = sta[10+8*in2,*]
  extenta = FLTARR(2,amx)

  this = WHERE(stb[7,*] NE '-999')
  stb = stb[*,this]
  bmx = N_ELEMENTS(stb[0,*])
  phi_1b = stb[10+8*in1,*]
  phi_2b = stb[10+8*in2,*]
  extentb = FLTARR(2,bmx)

  tdr = '~/Documents/Data/HELCATS/tracks/'
  FOR i = 0,amx-1 DO BEGIN
     OPENR,100,tdr+sta[7,i]
     elo = [-999]
     WHILE ~EOF(100) DO BEGIN
        line = ''
        READF,100,line
        f = STRSPLIT(line,' ',/EXTRACT)
        elo = [elo,f[2]]
     ENDWHILE
     CLOSE,100
     extenta[0,i] = MIN(elo[1:-1])
     extenta[1,i] = MAX(elo[1:-1])
  ENDFOR

  FOR i = 0,bmx-1 DO BEGIN
     OPENR,100,tdr+stb[7,i]
     elo = [-999]
     WHILE ~EOF(100) DO BEGIN
        line = ''
        READF,100,line
        f = STRSPLIT(line,' ',/EXTRACT)
        elo = [elo,f[2]]
     ENDWHILE
     CLOSE,100
     extentb[0,i] = MIN(elo[1:-1])
     extentb[1,i] = MAX(elo[1:-1])
  ENDFOR

  emx = MAX([MAX(extenta[1,*]),MAX(extentb[1,*])])
  emn = MIN([MIN(extenta[1,*]),MIN(extentb[1,*])])
  extenta = 254.*(extenta-emn)/(emx-emn)
  extentb = 254.*(extentb-emn)/(emx-emn)

  clr = INDGEN(256)
  bar = FLTARR(2,256)
  bar[0,*] = clr
  bar[1,*] = clr
  b_arr = (bar[0,*]/256.)*(emx-emn)+emn

  SET_PLOT,'PS'
  pdr = '~/Documents/Plots/'
  dr = 'HELCATS/stats/'
  fnm = 'phi'+fits[in1]+'_vs_phi'+fits[in2]
  DEVICE,XSIZE=12,YSIZE=9.5,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
         DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
  !P.MULTI=[0,1,2]
  LOADCT,39
  USERSYM,[-1,0,1,0,-1],[0,1,0,-1,0],THICK=2,/FILL

  PLOT,phi_1a,phi_2a,PSYM=4,/NODATA,$
       POSITION=[0.20,0.20,0.80,0.91],$
       XRANGE=[-180,180]*1,/XSTYLE,XTITLE='!7u!X!D'+fits[in1]+'!N(!Eo!N)',$
       XTICKINTERVAL=90,XMINOR=10.,XTICKLEN=-0.03,$
       YRANGE=[-180,180]*1,/YSTYLE,YTITLE='!7u!X!D'+fits[in2]+'!N(!Eo!N)',$
       YTICKINTERVAL=90,YMINOR=10.,YTICKLEN=-0.03,$
       CHARSIZE=3,CHARTHICK=3
  PLOTS,[-180,180],[-180,180],LINESTYLE=2,THICK=3
  PLOTS,[-180,180],[0,0],LINESTYLE=2,THICK=3
  PLOTS,[0,0],[-180,180],LINESTYLE=2,THICK=3
  FOR i = 0,amx-1 DO BEGIN
     IF (phi_2a[i] GT 180) THEN phi_2a[i] = phi_2a[i]-360.
     PLOTS,phi_1a[i],phi_2a[i],COLOR=extenta[1,i],PSYM=8,THICK=3
  ENDFOR
  FOR i = 0,bmx-1 DO BEGIN
     IF (phi_2b[i] GT 180) THEN phi_2b[i] = phi_2b[i]-360.
     PLOTS,phi_1b[i],phi_2b[i],COLOR=extentb[1,i],PSYM=8,THICK=3
     PLOTS,phi_1b[i],phi_2b[i],COLOR=255,PSYM=8,THICK=3,SYMSIZE=0.5
  ENDFOR

  CONTOUR,bar,[0,1],b_arr, $
          POSITION = [0.98,0.09,0.99,0.91], $
          LEVELS = clr, /XSTYLE, /YSTYLE, $
          C_COLORS = clr, /FILL, $
          YTITLE = '!7e!X!Dmax !N(!Eo!N)',$
          XTICKS = 1,XTICKFORMAT='(A1)',$
          CHARSIZE=3,CHARTHICK=3

  DEVICE, /CLOSE_FILE

  RETURN
END
