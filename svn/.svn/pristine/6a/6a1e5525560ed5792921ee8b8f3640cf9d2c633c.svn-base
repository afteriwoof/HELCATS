;; Plot time elongation data from STEREO-A & B WP3 catalogues
;; Fitted tracks are overplotted

PRO TIME_ELONGATION

  l0 = [0.,30.,90.]*!pi/190.
  lbl = ['FP','SSE','HM']

  READ_WP3_V2,sta,stb

  cx = WHERE(sta[8,*] NE -999)
  sta = sta[*,cx]
  FOR k = 0,N_ELEMENTS(cx)-1 DO BEGIN
     ca = k

     da = STRSPLIT(sta[0,ca],'_',/EXTRACT)
     da = da[2]+'_'+da[3]

     ta = sta[7,ca]
     READ_TRACKS,ta,tai_a,elon_a
     time_a = tai2julian(tai_a)
     va = FIX([[sta[8,ca],sta[9,ca]],$
               [sta[16,ca],sta[17,ca]],$
               [sta[24,ca],sta[25,ca]]])
     pa = [[sta[10,ca],sta[11,ca]],$
           [sta[18,ca],sta[19,ca]],$
           [sta[26,ca],sta[27,ca]]]*!pi/180.
     la = TAI2JULIAN([sta[15,ca],sta[23,ca],sta[31,ca]])
if (da NE '20090626_01') THEN continue     
     cb = WHERE(stb[0,*] EQ 'HCME_B__'+da)
     ;; IF (TOTAL(cb) EQ -1) THEN CONTINUE
     ;; IF (stb[8,cb] EQ '-999') THEN CONTINUE

     tb = stb[7,cb]
     READ_TRACKS,tb,tai_b,elon_b
     time_b = tai2julian(tai_b)
     vb = FIX([[stb[8,cb],stb[9,cb]],$
               [stb[16,cb],stb[17,cb]],$
               [stb[24,cb],stb[25,cb]]])
     pb = [[stb[10,cb],stb[11,cb]],$
           [stb[18,cb],stb[19,cb]],$
           [stb[26,cb],stb[27,cb]]]*!pi/180.
     lb = TAI2JULIAN([stb[15,cb],stb[23,cb],stb[31,cb]])

     xr = [FLOOR(MIN([MIN(time_a),MIN(time_b)])),$
           CEIL(MAX([MAX(time_a),MAX(time_b)]))]
     yr = [0.0,88.0]
     
     ra = 0.962*1.5E8
     rb = 1.083*1.5E8
     eps = ((DINDGEN(1.0E3)/1.0E3)*(yr[1]-yr[0])+yr[0])*!pi/180.

     fa = DBLARR(3,3,1.0E3)
     fb = DBLARR(3,3,1.0E3)
     sa = STRARR(3,2)
     sb = STRARR(3,2)
     FOR i0 = 0,2 DO BEGIN
        fa[i0,0,*] = la[i0] + ra*SIN(eps)*(1+SIN(l0[i0])) /$
                     ((86400.*va[0,i0])*(SIN(eps+pa[0,i0])+SIN(l0[i0])))
        fa[i0,1,*] = la[i0] + ra*SIN(eps)*(1+SIN(l0[i0])) /$
                     ((86400.*(va[0,i0]+va[1,i0])*(SIN(eps+(pa[0,i0]+pa[1,i0]))+SIN(l0[i0]))))
        fa[i0,2,*] = la[i0] + ra*SIN(eps)*(1+SIN(l0[i0])) /$
                     ((86400.*(va[0,i0]-va[1,i0])*(SIN(eps+(pa[0,i0]-pa[1,i0]))+SIN(l0[i0]))))
        sa[i0,0] = STRING(sta[i0*8+8,ca],FORMAT='(I4)')
        sa[i0,1] = STRING(sta[i0*8+10,ca],FORMAT='(I3)')
        
        fb[i0,0,*] = lb[i0] + rb*SIN(eps)*(1+SIN(l0[i0])) /$
                     ((86400.*vb[0,i0])*(SIN(eps+pb[0,i0])+SIN(l0[i0])))
        fb[i0,1,*] = lb[i0] + rb*SIN(eps)*(1+SIN(l0[i0])) /$
                     ((86400.*(vb[0,i0]+vb[1,i0])*(SIN(eps+(pb[0,i0]+pb[1,i0]))+SIN(l0[i0]))))
        fb[i0,2,*] = lb[i0] + rb*SIN(eps)*(1+SIN(l0[i0])) /$
                     ((86400.*(vb[0,i0]-vb[1,i0])*(SIN(eps+(pb[0,i0]-pb[1,i0]))+SIN(l0[i0]))))
        sb[i0,0] = STRING(stb[i0*8+8,cb],FORMAT='(I4)')
        sb[i0,1] = STRING(stb[i0*8+10,cb],FORMAT='(I3)')
     ENDFOR
     
     SET_PLOT,'PS'
     pdr = '~/Documents/Plots/'
     dr = 'HELCATS/tracks/'
     fnm = da
     DEVICE,XSIZE=12,YSIZE=6,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
            DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8
     !P.MULTI=[0,1,2]
     LOADCT,39
     
     csz = 1.5
     thk = 6.0
     dummy = LABEL_DATE(DATE_FORMAT='%H:%I!C%D %M')
     
     PLOT,time_a,elon_a,$
          ;; POSITION=[0.10,0.56,0.94,0.98],$
          POSITION=[0.08,0.12,0.48,0.98],$
          XTICKINTERVAL=1.0,XMINOR=12,$
          XRANGE=xr,/XSTYLE,XTICKFORMAT='LABEL_DATE',$
          ;; XRANGE=xr,/XSTYLE,XTICKFORMAT='(A1)',$
          YTITLE='elongation (degrees)',$
          YRANGE=yr,/YSTYLE,$
          PSYM=4,$
          CHARSIZE=csz,CHARTHICK=4.0
     FOR i0 = 0,2 DO BEGIN
        OPLOT,fa[i0,0,*],eps*180./!pi,COLOR=54+100*i0,THICK=thk
        OPLOT,fa[i0,1,*],eps*180./!pi,LINESTYLE=1,COLOR=54+100*i0,THICK=thk
        OPLOT,fa[i0,2,*],eps*180./!pi,LINESTYLE=1,COLOR=54+100*i0,THICK=thk
        XYOUTS,fa[0,0,0],yr[1]-10-5*i0,sa[i0,0]+'kms!E-1!N   '+sa[i0,1]+'!Eo!N',$
               COLOR=54+100*i0,CHARSIZE=csz,CHARTHICK=4
     ENDFOR
     OPLOT,time_a,elon_a,PSYM=7
     OPLOT,xr,[24,24],LINESTYLE=2,COLOR=0,THICK=thk
     XYOUTS,xr[0]+0.2,yr[1]-5,'HI-2A',CHARSIZE=csz,CHARTHICK=4.0
     XYOUTS,xr[0]+0.2,19,'HI-1A',CHARSIZE=csz,CHARTHICK=4.0

     PLOT,time_b,elon_b,/nodata,$
          ;; POSITION=[0.10,0.12,0.94,0.54],$
          POSITION=[0.56,0.12,0.96,0.98],$
          ;; XTITLE='date',$
          XTICKINTERVAL=1.0,XMINOR=12,$
          XRANGE=xr,/XSTYLE,XTICKFORMAT='LABEL_DATE',$
          ;; YTITLE='elongation (degrees)',$
          YRANGE=yr,/YSTYLE,YTICKFORMAT='(A1)',$
          PSYM=4,$
          CHARSIZE=csz,CHARTHICK=4.0
     FOR i0 = 0,2 DO BEGIN
     ;;    OPLOT,fb[i0,0,*],eps*180./!pi,COLOR=54+100*i0,THICK=thk
     ;;    OPLOT,fb[i0,1,*],eps*180./!pi,LINESTYLE=1,COLOR=54+100*i0,THICK=thk
     ;;    OPLOT,fb[i0,2,*],eps*180./!pi,LINESTYLE=1,COLOR=54+100*i0,THICK=thk
     ;;    XYOUTS,fb[0,0,0],yr[1]-10-5*i0,sb[i0,0]+'kms!E-1!N   '+sb[i0,1]+'!Eo!N',$
     ;;           COLOR=54+100*i0,CHARSIZE=csz,CHARTHICK=4
        PLOTS,[xr[0]+0.2,xr[0]+0.6],[44-4*i0,44-4*i0],COLOR=54+100*i0,THICK=thk
        XYOUTS,xr[0]+0.7,44-4*i0,lbl[i0],CHARSIZE=csz,CHARTHICK=4.0
     ENDFOR
     ;; OPLOT,time_b,elon_b,PSYM=7
     OPLOT,xr,[24,24],LINESTYLE=2,COLOR=0,THICK=thk
     XYOUTS,xr[0]+0.2,yr[1]-5,'HI-2B',CHARSIZE=csz,CHARTHICK=4.0
     XYOUTS,xr[0]+0.2,19,'HI-1B',CHARSIZE=csz,CHARTHICK=4.0

     DEVICE, /CLOSE_FILE

  ENDFOR
  RETURN
END
