PRO EPS_TIME

  l0 = [0.,30.,90.]*!pi/180.
  lbl = ['FP ','SSE','HM ']

  READ_WP3_V2,sta,stb

  cx = WHERE(sta[8,*] NE -999)
  sta = sta[*,cx]
  FOR k = 0,N_ELEMENTS(cx)-1 DO BEGIN
     ca = k

     da = STRSPLIT(sta[0,ca],'_',/EXTRACT)
     da = da[2]+'_'+da[3]

     ta = sta[7,ca]
     READ_TRACKS,ta,tai_a,elon_a
     elon_a = elon_a*!pi/180.
     time_a = TAI2JULIAN(tai_a)
     va = FIX([[sta[8,ca],sta[9,ca]],$
               [sta[16,ca],sta[17,ca]],$
               [sta[24,ca],sta[25,ca]]])
     pa = [[sta[10,ca],sta[11,ca]],$
           [sta[18,ca],sta[19,ca]],$
           [sta[26,ca],sta[27,ca]]]*!pi/180.
     la = TAI2JULIAN([sta[15,ca],sta[23,ca],sta[31,ca]])
     IF (da NE '20090626_01') THEN CONTINUE    

     xr = [FLOOR(MIN(time_a)),CEIL(MAX(time_a))+2.5]
     xa = (DINDGEN(1.0E3)/1.0E3)*(xr[1]-xr[0])+xr[0]
     yr = [1.0E0,6.0E1]
     
     ra = 0.962*1.5E8
     ro = 6.96E5
     eps = (DINDGEN(1.0E3)/1.0E3)*90*!pi/180.

     fa = DBLARR(3,3,1.0E3)
     sa = STRARR(3,2)
     ha = DBLARR(3,N_ELEMENTS(elon_a))
     FOR i0 = 0,2 DO BEGIN
        fa[i0,0,*] = la[i0] + ra*SIN(eps)*(1+SIN(l0[i0])) /$
                     ((86400.*va[0,i0])*(SIN(eps+pa[0,i0])+SIN(l0[i0])))
        fa[i0,1,*] = la[i0] + ra*SIN(eps)*(1+SIN(l0[i0])) /$
                     ((86400.*(va[0,i0]+va[1,i0])*(SIN(eps+(pa[0,i0]+pa[1,i0]))+SIN(l0[i0]))))
        fa[i0,2,*] = la[i0] + ra*SIN(eps)*(1+SIN(l0[i0])) /$
                     ((86400.*(va[0,i0]-va[1,i0])*(SIN(eps+(pa[0,i0]-pa[1,i0]))+SIN(l0[i0]))))
        sa[i0,0] = STRING(sta[i0*8+8,ca],FORMAT='(I4)')
        sa[i0,1] = STRING(sta[i0*8+10,ca],FORMAT='(I3)')
     ENDFOR

     SET_PLOT,'PS'
     pdr = '~/Documents/Plots/'
     dr = 'HELCATS/jmap/'
     fnm = da
     DEVICE,XSIZE=8,YSIZE=6,/INCHES,FILENAME=pdr+dr+fnm+'.ps',$
            DECOMPOSED=0,/COLOR,BITS_PER_PIXEL=8,/ENCAPSULATED
     !P.MULTI=[0,1,1]
     LOADCT,39

     csz = 1.5
     thk = 6.0
     dummy = LABEL_DATE(DATE_FORMAT='%H:%I!C%D %M')
     PLOT,time_a,elon_a*180./!pi,$
          ;; POSITION=[0.08,0.12,0.48,0.98],$
          XTICKINTERVAL=1.0,XMINOR=12,$
          XRANGE=xr,/XSTYLE,XTICKFORMAT='LABEL_DATE',$
          YTITLE='elongation (degrees)',$
          YRANGE=yr,/YSTYLE,$
          PSYM=4,$
          CHARSIZE=csz,CHARTHICK=4.0
     FOR i0 = 0,2 DO BEGIN
        OPLOT,fa[i0,0,*],eps*180./!pi,COLOR=54+100*i0,THICK=thk
        OPLOT,fa[i0,1,*],eps*180./!pi,LINESTYLE=1,COLOR=54+100*i0,THICK=thk
        OPLOT,fa[i0,2,*],eps*180./!pi,LINESTYLE=1,COLOR=54+100*i0,THICK=thk
     ENDFOR
     OPLOT,time_a,elon_a*180./!pi,PSYM=4
     FOR i0= 0,2 DO BEGIN
        XYOUTS,fa[i0,0,0]+1.0,50-5*i0,lbl[i0]+' v='+sa[i0,0]+'kms!E-1!N   '+$
               '!4u!X='+sa[i0,1]+'!Eo!N',$
               COLOR=54+100*i0,CHARSIZE=csz,CHARTHICK=4
     ENDFOR

     DEVICE, /CLOSE_FILE

  ENDFOR
  RETURN
END
