PRO V_VS_PHI

  READ_WP3_V2,sta,stb

  this = WHERE(sta[7,*] NE '-999')
  sta = sta[*,this]
  amx = N_ELEMENTS(sta[0,*])
  v_fp_a = sta[8,*]
  phi_fp_a = sta[10,*]
  v_se_a = sta[16,*]
  phi_se_a = sta[18,*]
  v_hm_a = sta[24,*]
  phi_hm_a = sta[26,*]
  extenta = FLTARR(2,amx)

  this = WHERE(stb[7,*] NE '-999')
  stb = stb[*,this]
  bmx = N_ELEMENTS(stb[0,*])
  v_fp_b = stb[8,*]
  phi_fp_b = stb[10,*]
  v_se_b = stb[16,*]
  phi_se_b = stb[18,*]
  v_hm_b = stb[24,*]
  phi_hm_b = stb[26,*]
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

  clr = INDGEN(256)
  bar = FLTARR(2,256)
  bar[0,*] = clr
  bar[1,*] = clr
  b2_arr = (bar[0,*]/256.)*91

  SET_PLOT,'PS'
  pdr = '~/Documents/Plots/'
  dr = 'HELCATS/stats/'
  fnm = 'v_vs_phi_fp'
  DEVICE,XSIZE=12,YSIZE=9.5,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
         DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
  !P.MULTI=[0,1,2]
  LOADCT,39
  USERSYM,[-1,0,1,0,-1],[0,1,0,-1,0],THICK=3,/FILL

  PLOT,phi_fp_a,v_fp_a,PSYM=4,/NODATA,$
       POSITION=[0.20,0.20,0.80,0.91],$
       XRANGE=[-180,180]*1,/XSTYLE,XTITLE='!7u!X!DFP!N(!Eo!N)',$
       XTICKINTERVAL=90,XMINOR=10.,XTICKLEN=-0.03,$
       YRANGE=[0,2.0E3]*1,/YSTYLE,YTITLE='V!DFP!N (kms!E-1!N)',$
       YTICKINTERVAL=300,YMINOR=6.,YTICKLEN=-0.03,$
       CHARSIZE=3,CHARTHICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  PLOTS,[0,0],[0,2.0E3],LINESTYLE=2,THICK=3
  FOR i = 0,amx-1 DO BEGIN
     IF (phi_fp_a[i] GT 180) THEN phi_fp_a[i] = phi_fp_a[i]-360.
     PLOTS,phi_fp_a[i],v_fp_a[i],COLOR=extenta[1,i],PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  ENDFOR
  FOR i = 0,bmx-1 DO BEGIN
     IF (phi_fp_b[i] GT 180) THEN phi_fp_b[i] = phi_fp_b[i]-360.
     PLOTS,phi_fp_b[i],v_fp_b[i],COLOR=extentb[1,i],PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
     PLOTS,phi_fp_b[i],v_fp_b[i],COLOR=255,PSYM=8,THICK=3,SYMSIZE=0.5,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  ENDFOR

  CONTOUR,bar,[0,1],b_arr, $
          POSITION = [0.98,0.09,0.99,0.91], $
          LEVELS = clr, /XSTYLE, /YSTYLE, $
          C_COLORS = clr, /FILL, $
          YTITLE = '!7e!X!Dmax !N(!Eo!N)',$
          XTICKS = 1,XTICKFORMAT='(A1)',$
          CHARSIZE=3,CHARTHICK=3

  DEVICE, /CLOSE_FILE




  SET_PLOT,'PS'
  pdr = '~/Documents/Plots/'
  dr = 'HELCATS/stats/'
  fnm = 'v_vs_phi_hm'
  DEVICE,XSIZE=12,YSIZE=9.5,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
         DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
  !P.MULTI=[0,1,2]
  LOADCT,39
  USERSYM,[-1,0,1,0,-1],[0,1,0,-1,0],THICK=3,/FILL

  PLOT,phi_hm_a,v_hm_a,PSYM=4,/NODATA,$
       POSITION=[0.20,0.20,0.80,0.91],$
       XRANGE=[-180,180]*1,/XSTYLE,XTITLE='!7u!X!DHM!N(!Eo!N)',$
       XTICKINTERVAL=90,XMINOR=10.,XTICKLEN=-0.03,$
       YRANGE=[0,2.0E3]*1,/YSTYLE,YTITLE='V!DHM!N (kms!E-1!N)',$
       YTICKINTERVAL=300,YMINOR=6.,YTICKLEN=-0.03,$
       CHARSIZE=3,CHARTHICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  PLOTS,[0,0],[0,2.0E3],LINESTYLE=2,THICK=3
  FOR i = 0,amx-1 DO BEGIN
     IF (phi_hm_a[i] GT 180) THEN phi_hm_a[i] = phi_hm_a[i]-360.
     PLOTS,phi_hm_a[i],v_hm_a[i],COLOR=extenta[1,i],PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  ENDFOR
  FOR i = 0,bmx-1 DO BEGIN
     IF (phi_hm_b[i] GT 180) THEN phi_hm_b[i] = phi_hm_b[i]-360.
     PLOTS,phi_hm_b[i],v_hm_b[i],COLOR=extentb[1,i],PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
     PLOTS,phi_hm_b[i],v_hm_b[i],COLOR=255,PSYM=8,THICK=3,SYMSIZE=0.5,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  ENDFOR

  CONTOUR,bar,[0,1],b_arr, $
          POSITION = [0.98,0.09,0.99,0.91], $
          LEVELS = clr, /XSTYLE, /YSTYLE, $
          C_COLORS = clr, /FILL, $
          YTITLE = '!7e!X!Dmax !N(!Eo!N)',$
          XTICKS = 1,XTICKFORMAT='(A1)',$
          CHARSIZE=3,CHARTHICK=3

  DEVICE, /CLOSE_FILE




  SET_PLOT,'PS'
  pdr = '~/Documents/Plots/'
  dr = 'HELCATS/stats/'
  fnm = 'v_vs_phi_sse'
  DEVICE,XSIZE=12,YSIZE=9.5,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
         DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
  !P.MULTI=[0,1,2]
  LOADCT,39
  USERSYM,[-1,0,1,0,-1],[0,1,0,-1,0],THICK=3,/FILL

  PLOT,phi_se_a,v_se_a,PSYM=4,/NODATA,$
       POSITION=[0.20,0.20,0.80,0.91],$
       XRANGE=[-180,180]*1,/XSTYLE,XTITLE='!7u!X!DSSE!N(!Eo!N)',$
       XTICKINTERVAL=90,XMINOR=10.,XTICKLEN=-0.03,$
       YRANGE=[0,2.0E3]*1,/YSTYLE,YTITLE='V!DSSE!N (kms!E-1!N)',$
       YTICKINTERVAL=300,YMINOR=6.,YTICKLEN=-0.03,$
       CHARSIZE=3,CHARTHICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  PLOTS,[0,0],[0,2.0E3],LINESTYLE=2,THICK=3
  FOR i = 0,amx-1 DO BEGIN
     IF (phi_se_a[i] GT 180) THEN phi_se_a[i] = phi_se_a[i]-360.
     PLOTS,phi_se_a[i],v_se_a[i],COLOR=extenta[1,i],PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  ENDFOR
  FOR i = 0,bmx-1 DO BEGIN
     IF (phi_se_b[i] GT 180) THEN phi_se_b[i] = phi_se_b[i]-360.
     PLOTS,phi_se_b[i],v_se_b[i],COLOR=extentb[1,i],PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
     PLOTS,phi_se_b[i],v_se_b[i],COLOR=255,PSYM=8,THICK=3,SYMSIZE=0.5,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  ENDFOR

  CONTOUR,bar,[0,1],b_arr, $
          POSITION = [0.98,0.09,0.99,0.91], $
          LEVELS = clr, /XSTYLE, /YSTYLE, $
          C_COLORS = clr, /FILL, $
          YTITLE = '!7e!X!Dmax !N(!Eo!N)',$
          XTICKS = 1,XTICKFORMAT='(A1)',$
          CHARSIZE=3,CHARTHICK=3

  DEVICE, /CLOSE_FILE





  SET_PLOT,'PS'
  pdr = '~/Documents/Plots/'
  dr = 'HELCATS/stats/'
  fnm = 'v_vs_phi_all'
  DEVICE,XSIZE=12,YSIZE=9.5,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
         DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
  !P.MULTI=[0,1,2]
  LOADCT,39
  USERSYM,[-1,0,1,0,-1],[0,1,0,-1,0],THICK=3,/FILL

  PLOT,phi_se_a,v_se_a,PSYM=4,/NODATA,$
       POSITION=[0.20,0.20,0.80,0.91],$
       XRANGE=[-180,180]*1,/XSTYLE,XTITLE='!7u!X!DSSE!N(!Eo!N)',$
       XTICKINTERVAL=90,XMINOR=10.,XTICKLEN=-0.03,$
       YRANGE=[0,2.0E3]*1,/YSTYLE,YTITLE='V!DSSE!N (kms!E-1!N)',$
       YTICKINTERVAL=300,YMINOR=6.,YTICKLEN=-0.03,$
       CHARSIZE=3,CHARTHICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  PLOTS,[0,0],[0,2.0E3],LINESTYLE=2,THICK=3
  FOR i = 0,amx-1 DO BEGIN
     PLOTS,phi_fp_a[i],v_fp_a[i],COLOR=0,PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
     PLOTS,phi_se_a[i],v_se_a[i],COLOR=85,PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
     PLOTS,phi_hm_a[i],v_hm_a[i],COLOR=254,PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  ENDFOR
  FOR i = 0,bmx-1 DO BEGIN
     PLOTS,phi_fp_b[i],v_fp_b[i],COLOR=0,PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
     PLOTS,phi_fp_b[i],v_fp_b[i],COLOR=255,PSYM=8,THICK=3,SYMSIZE=0.5,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
     PLOTS,phi_se_b[i],v_se_b[i],COLOR=85,PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
     PLOTS,phi_se_b[i],v_se_b[i],COLOR=255,PSYM=8,THICK=3,SYMSIZE=0.5,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
     PLOTS,phi_hm_b[i],v_hm_b[i],COLOR=254,PSYM=8,THICK=3,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
     PLOTS,phi_hm_b[i],v_hm_b[i],COLOR=255,PSYM=8,THICK=3,SYMSIZE=0.5,NOCLIP=0,CLIP=[-180,0,180,2.0E3]
  ENDFOR

  CONTOUR,bar,[0,1],b2_arr, $
          POSITION = [0.98,0.09,0.99,0.91], $
          LEVELS = clr, /XSTYLE, /YSTYLE, $
          C_COLORS = clr, /FILL, $
          YTITLE = '!7k!X!DSSE !N(!Eo!N)',$
          XTICKS = 1,XTICKFORMAT='(A1)',$
          YTICKINTERVAL=10,YMINOR=5.,YTICKLEN=-0.03,$
          CHARSIZE=3,CHARTHICK=3

  DEVICE, /CLOSE_FILE

  RETURN
END
