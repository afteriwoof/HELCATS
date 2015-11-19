PRO SINGLE_FITS

  today = '300915'

  dir = '~/Documents/Data/HELCATS/catalogues/'
  ;; file = 'STEREO-A_CME_LIST_WP2_'+today+'.txt'
  file = 'STEREO-B_CME_LIST_WP2_'+today+'.txt'

  array = STRARR(7)
  imx = 0
  OPENR,100,dir+file
  WHILE ~EOF(100) DO BEGIN
     line = ''
     READF,100,line
     fields = STRSPLIT(line,'>< ',/EXTRACT)
     array = [[array],[fields]]
     imx = imx+1
  ENDWHILE
  CLOSE,100
  array = array[*,1:imx-1]
  imx = imx-1

  tracks = '/soft/ukssdc/share/Solar/HELCATS/tracks/'
  FOR i = 0,imx-1 DO BEGIN
  ;; i=1
     PRINT,array[0,i]
     years = STRSPLIT(array[1,i],' :TZ-',/EXTRACT)
  ;; IF (years[0] EQ '2012') THEN CONTINUE
     file = FILE_SEARCH(tracks+array[0,i]+'*dat')
  IF (STRLEN(file) EQ 0) THEN CONTINUE
  IF(FILE_LINES(file) LT 10) THEN CONTINUE
     done = FILE_SEARCH(tracks+array[0,i]+'*dat_single')
  IF (STRLEN(done) NE 0) THEN CONTINUE 
     track_data = STRARR(5)
     jmx= 0 
     OPENR,101,file
     WHILE ~EOF(101) DO BEGIN
        line = ''
        READF,101,line
        fields = STRSPLIT(line,' ',/EXTRACT)
        track_data = [[track_data],[fields]]
        jmx = jmx+1
     ENDWHILE
     CLOSE,101
     track_data = track_data[*,1:jmx-1]
     jmx = jmx-1

     order = SORT(track_data[1,*])
     u_arr = STRARR(jmx)
     e_arr = DBLARR(jmx)
     u_arr[*] = track_data[1,order]+'Z'
     ;; t_arr = track_data[1,order]
     e_arr[*] = track_data[2,order]
     spacecraft = track_data[4,0]
     usepa = track_data[3,0]

     t_arr = UTC2TAI(u_arr)

     ;; avtime = u_arr[0]
     avtime=TAI2UTC((min(t_arr)+max(t_arr))/2.0,/ccsds)
     rs=(GET_STEREO_LONLAT(avtime,spacecraft,/degrees,system='HEE'))[0]
     re=(GET_STEREO_LONLAT(avtime,'Earth',/degrees,system='HEE'))[0]

     OPENW,99,file+'_single'
     printf,99,format='(a-43,3x,i10)','Transient number:',0
     printf,99,format='(a-43,3x,a10)','STEREO spacecraft:',spacecraft
     printf,99,format='(a-43,3x,f10.2)','Position angle (deg):',usepa
     
     FOR fittype=0,2 DO BEGIN
              
        if fittype eq 0 then fitstr='Fixed Phi     '
        if fittype eq 1 then fitstr='SSE (30 deg)  '
        if fittype eq 2 then fitstr='Harm. Mean    '
              
        times=t_arr
        elongations=e_arr
        if fittype eq 0 then ans=CME_DIRECTION_FIT_FUNC2(times,elongations,rs,re,$
                                                         pred_launch=launch,$
                                                         pred_arrival=arrival)
        if fittype eq 1 then ans=CME_DIRECTION_FIT_FUNC2(times,elongations,rs,re,$
                                                         pred_launch=launch,$
                                                         pred_arrival=arrival,$
                                                         ssex_angle=30)
        if fittype eq 2 then ans=CME_DIRECTION_FIT_FUNC2(times,elongations,rs,re,$
                                                         pred_launch=launch,$
                                                         pred_arrival=arrival,$
                                                         /harmonic_mean)
        vout=ans(0)
        verr=ans(1)
        bout=ans(2)
        berr=ans(3)
        
        IF usepa eq 999.0 THEN BEGIN
           
           sclon=(GET_STEREO_LONLAT(avtime,spacecraft,/degrees,$
                                    system='HEE'))[1]
           IF spacecraft eq 'A' THEN lon=sclon-bout ELSE lon=sclon+bout
           coord1=[lon,0.0]     ;HEE
           coord2=coord1        ;HEEQ
           CONVERT_STEREO_LONLAT,spacecraft=spacecraft,avtime,$
                                 coord2,'HEE','HEEQ',/degrees
           
        ENDIF ELSE BEGIN
                 
           beta=bout*!pi/180.0
           pa=usepa*!pi/180.0
           b0=(GET_STEREO_LONLAT(avtime,spacecraft,system='HCI'))[2]
           lat=asin(cos(b0)*sin(beta)*cos(pa)+sin(b0)*cos(beta))
           lon=atan(sin(pa)*sin(beta),cos(b0)*cos(beta)-sin(beta)*cos(pa)*$
                    sin(b0))
           sclon=(GET_STEREO_LONLAT(avtime,spacecraft,/degrees,$
                                    system='HEEQ'))[1]
           lon=sclon-lon*180.0/!pi
           coord2=[lon,lat*180.0/!pi] ;HEEQ
           coord1=coord2              ;HEE
           CONVERT_STEREO_LONLAT,spacecraft=spacecraft,avtime,$
                                 coord1,'HEEQ','HEE',/degrees
           
        ENDELSE
        
        printf,99,format='(a-43,3x,f10.2,f10.2)',fitstr+$
               'Best fit/error phi (deg):',bout,berr
        printf,99,format='(a-43,3x,f10.2,f10.2)',fitstr+$
               'Best fit/error Vr (km/s):',vout,verr
        printf,99,format='(a-43,3x,f10.2,f10.2)',fitstr+$
               'HEEQ lon/lat (deg):',coord2
        printf,99,format='(a-43,3x,f10.2,f10.2)',fitstr+$
               'HEE lon/lat (deg):',coord1
        printf,99,format='(a-43,a23)',fitstr+'Launch time estimate:',launch
        printf,99,format='(a-43,a23)',fitstr+'1 AU arrival time estimate:',arrival
        
                                ;ANGLE CHECK
        scvals=GET_STEREO_LONLAT(avtime,spacecraft,/degrees,system='HEEQ')
        l1=scvals(2)*!pi/180.0                   ;sc lat
        l2=coord2(1)*!pi/180.0                   ;transient lat
        dL=(scvals(1)-coord2(0))*!pi/180.0       ;lon diff
        d=acos(cos(l1)*cos(l2)*cos(dL)+sin(l1)*sin(l2))*180.0/!pi
        ;; print,d
        
        scvals=GET_STEREO_LONLAT(avtime,spacecraft,/degrees,system='HEE')
        l1=scvals(2)*!pi/180.0                   ;sc lat
        l2=coord1(1)*!pi/180.0                   ;transient lat
        dL=(scvals(1)-coord1(0))*!pi/180.0       ;lon diff
        d=acos(cos(l1)*cos(l2)*cos(dL)+sin(l1)*sin(l2))*180.0/!pi
        ;; print,d		
        
     ENDFOR
     CLOSE,99
  ENDFOR
RETURN
END
     
