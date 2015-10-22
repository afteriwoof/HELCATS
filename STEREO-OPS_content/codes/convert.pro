;; Takes 'raw' data (STA2007.txt...) converts to observational
;; catalogue (STEREO-A_CME_LIST_WP2_DDMMYY.txt)


PRO CONVERT,today
  crafts = ['A','B']
  years = ['2007','2008','2009','2010','2011','2012','2013'];,'2014']
  halos = [' No','Yes']
  quality = ['poor','fair','good']
  lim = [' ','<','>']
   FOR c = 0,1 DO BEGIN
     craft = crafts[c]
     dir = '/soft/ukssdc/share/Solar/HELCATS/catalog/'
     outfile = dir+'STEREO-'+craft+'_CME_LIST_WP2_'+today+'.txt'
     OPENW,101,outfile
     FOR y = 0,N_ELEMENTS(years)-1 DO BEGIN
        year = years[y]
        i = -1
        f0 = 0
        id = 1
        cc = [-1,-1]
        infile = dir+'ST'+craft+year+'.txt'
        OPENR,100,infile
        WHILE ~EOF(100) DO BEGIN
           i = i+1
           line = ''
           READF,100,line
           fields = STRSPLIT(line,/EXTRACT)
        IF (i LT 2) THEN CONTINUE
           cc = [cc,fields[0]]

           ;; Unique identifier
           IF (cc[i] EQ cc[i-1]) AND (f0 GT 0) THEN BEGIN
           ;; IF (cc[i] EQ cc[i-1]) THEN BEGIN
              id = id+1
           ENDIF ELSE BEGIN
              id = 1
           ENDELSE

           f1 = FIX(STRSPLIT(fields[4],'><',/EXTRACT))
           f2 = FIX(STRSPLIT(fields[6],'><',/EXTRACT))
           f0 = FIX(fields[7])
           IF (f0 EQ 0) AND (ABS(FIX(f1)-FIX(f2)) GE 20) THEN f0 = 1

           ;; Halo ?
           IF (N_ELEMENTS(fields) GE 9) THEN BEGIN
              halo = halos[STRMATCH(fields[8],'*x*')]
           ENDIF ELSE BEGIN
              halo = halos[0]
           ENDELSE

           ;; Greater/Less than ?
           l0 = lim[0]
           l1 = lim[0]
           IF (STRMATCH(fields[4],'*<*') EQ 1) THEN BEGIN
              l0 = lim[1]
              fields[4] = STRMID(fields[4],1,3)
           ENDIF
           IF (STRMATCH(fields[6],'*>*') EQ 1) THEN BEGIN
              l1 = lim[2]
              fields[6] = STRMID(fields[6],1,3)
           ENDIF

       IF ((fields[1] LE 3) AND (y EQ 0)) THEN CONTINUE
       IF (f0 EQ 0) THEN CONTINUE
          IF (c EQ 0) THEN BEGIN
             PRINTF,101,'HCME_'+craft+'__'+year+$
                    STRING(fields[1],FORMAT='(I02)')+STRING(fields[0],FORMAT='(I02)')+'_'+$
                    STRING(id,FORMAT='(I02)')+'     '+year+'-'+STRING(fields[1],FORMAT='(I02)')+'-'+$
                    STRING(fields[0],FORMAT='(I02)')+'T'+STRING(fields[2],FORMAT='(I02)')+':'+$
                    STRING(fields[3],FORMAT='(I02)')+'Z      '+craft+'    '+l0+' '+$
                    STRING(fields[4],FORMAT='(A3)')+'    '+l1+' '+STRING(fields[6],FORMAT='(A3)')+$
                    '    '+halo+'      '+STRING(quality[fields[7]]);;+'    '+STRING(fields[5],FORMAT='(A3)')
             ;; IF (fields[4] GE fields[6]) THEN PRINT,'A  ',fields[4],'  ',fields[6]
             IF (f1 GE f2) THEN PRINT,'A  ',f1,'  ',f2
          ENDIF ELSE BEGIN
             PRINTF,101,'HCME_'+craft+'__'+year+$
                    STRING(fields[1],FORMAT='(I02)')+STRING(fields[0],FORMAT='(I02)')+'_'+$
                    STRING(id,FORMAT='(I02)')+'     '+year+'-'+STRING(fields[1],FORMAT='(I02)')+'-'+$
                    STRING(fields[0],FORMAT='(I02)')+'T'+STRING(fields[2],FORMAT='(I02)')+':'+$
                    STRING(fields[3],FORMAT='(I02)')+'Z      '+craft+'    '+l1+' '+$
                    STRING(fields[6],FORMAT='(A3)')+'    '+l0+' '+STRING(fields[4],FORMAT='(A3)')+$
                    '    '+halo+'      '+STRING(quality[fields[7]]);;+'    '+STRING(fields[5],FORMAT='(A3)')
             IF (fields[4] GE fields[6]) THEN PRINT,'B  ',fields[4],'  ',fields[6],'  ',$
                                                    year+STRING(fields[1],FORMAT='(I02)')+$
                                                    STRING(fields[0],FORMAT='(I02)')+'_'+$
                                                    STRING(id,FORMAT='(I02)')
          ENDELSE
       ENDWHILE
        CLOSE,100
     ENDFOR
     CLOSE,101
  ENDFOR
  RETURN
END
