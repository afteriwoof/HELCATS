PRO V_VS_V,in1,in2

  READ_WP3_V2,sta,stb
  fits = ['FP','SSE','HM']

  this = WHERE(sta[8,*] NE '-999')
  sta = sta[*,this]
  amx = N_ELEMENTS(sta[0,*])
  v_1a = sta[8+in1*8,*]
  v_2a = sta[8+in2*8,*]
  extenta = FLTARR(2,amx)

  this = WHERE(stb[8,*] NE '-999')
  stb = stb[*,this]
  bmx = N_ELEMENTS(stb[0,*])
  v_1b = stb[8+in1*8,*]
  v_2b = stb[8+in2*8,*]
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
  fnm = 'v'+fits[in1]+'_vs_v'+fits[in2]
  DEVICE,XSIZE=12,YSIZE=9.5,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
         DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
  !P.MULTI=[0,1,2]
  LOADCT,39
  USERSYM,[-1,0,1,0,-1],[0,1,0,-1,0],THICK=2,/FILL

  PLOT,v_1a,v_2a,PSYM=4,/NODATA,$
       POSITION=[0.20,0.20,0.80,0.91],$
       XRANGE=[0,2.0E3],/XSTYLE,XTITLE='V!D'+fits[in1]+'!N (kms!E-1!N)',$
       XTICKINTERVAL=300,XMINOR=6.,XTICKLEN=-0.03,$
       YRANGE=[0,2.0E3],/YSTYLE,YTITLE='V!D'+fits[in2]+'!N (kms!E-1!N)',$
       YTICKINTERVAL=300,YMINOR=6.,YTICKLEN=-0.03,$
       CHARSIZE=3,CHARTHICK=3
  PLOTS,[0,2.0E3],[0,2.0E3],LINESTYLE=2,THICK=4
  FOR i = 0,amx-1 DO BEGIN
     PLOTS,v_1a[i],v_2a[i],COLOR=extenta[1,i],PSYM=8,THICK=4,NOCLIP=0,CLIP=[0,0,2.0E3,2.0E3]
  ENDFOR
  FOR i = 0,bmx-1 DO BEGIN
     PLOTS,v_1b[i],v_2b[i],COLOR=extentb[1,i],PSYM=8,THICK=4,NOCLIP=0,CLIP=[0,0,2.0E3,2.0E3]
     PLOTS,v_1b[i],v_2b[i],COLOR=255,PSYM=8,THICK=4,SYMSIZE=0.5,NOCLIP=0,CLIP=[0,0,2.0E3,2.0E3]
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
