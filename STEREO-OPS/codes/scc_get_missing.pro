function scc_get_missing,hdr, SILENT=silent
;+
; $Id: scc_get_missing.pro,v 1.12 2007/10/31 18:15:03 nathan Exp $
;
; Project   : STEREO SECCHI
;                   
; Name      : scc_get_missing
;               
; Purpose   : This function returns the index of the missing
;             pixels.
;               
; Explanation: The function uses the MISSLIST keyword. Finds all the 
;              image index of all superpixels that are missing in 
;              the image.
;               
; Use       : IDL> missing_index = scc_miss_pixels(hdr)
;    
; Inputs    : hdr -image header, either fits or SECCHI structure
;
; Outputs   : missing_index - the longword vector containing the
;                        1D subscripts of the missing pixels 
;
; Keywords  : 
;
; Restictions: Does not handle COMPRSSN=98 (8 segments) 
;
; Calls     : BNTOINT
;            
;               
; Category    : Masking, Missing Blocks
;               
; Prev. Hist. : None.
;
; Written     : Robin C Colaninno NRL/GMU August 2006
;               Rewrite : June 2007
;
; $Log: scc_get_missing.pro,v $
; Revision 1.12  2007/10/31 18:15:03  nathan
; Left in stopcd ~/secchi/idl/prep
;
; Revision 1.11  2007/10/31 18:10:17  nathan
; forgot to test, had to fix data type error
;
; Revision 1.10  2007/10/31 18:00:22  nathan
; Made output in 1-segment case pixels not superpixels; updated comments;
; print error message if hdr.comprssn=98
;
; Revision 1.9  2007/10/31 17:33:38  nathan
; added 1-segment ICER case, and /SILENT (Bug 246)
;
; Revision 1.8  2007/06/22 21:03:16  colaninn
; complete overhaul now works for all compressions
;
; Revision 1.5  2007/05/21 20:16:06  colaninn
; added silent keyword
;
;-     
tyme=systime(1)
IF(DATATYPE(hdr) NE 'STC') THEN hdr=SCC_FITSHDR2STRUCT(hdr)
IF ~strmatch(TAG_NAMES(hdr,/STRUCTURE_NAME),'SECCHI_HDR_STRUCT*') THEN $
MESSAGE, 'ONLY SECCHI HEADER STRUCTURE ALLOWED'

;--Convert MISSLIST to Superpixel 1D index
base =34

len = strlen(hdr.MISSLIST)
if len eq 0 then return, 0

IF fix(len/2) NE len/2.0 THEN BEGIN
  misslist=' '+hdr.MISSLIST
  len = len+1
ENDIF ELSE misslist=hdr.MISSLIST

dex = (indgen(len/2)*2)
misslist = bntoint(strtrim(strmid(misslist,dex,2),2),base)

n = n_elements(misslist)
IF n NE hdr.NMISSING THEN BEGIN
  message,'MISSLIST does not equal NMISSING',/inform
  RETURN, 0
ENDIF
;-----------------------------------------

;--Rice Compression and H-compress--------
IF hdr.COMPRSSN LT 89 THEN BEGIN
  ;--Define Superpixel size and length   
  blksz = 64L
  blklen = blksz^2
  missing = lonarr(n*blklen)

  ;--Calculate the 2D index of the Superpixel
  ax1=hdr.naxis1/blksz 
  ax2=hdr.naxis2/blksz
  blocks=[[misslist MOD ax1] ,[misslist/ax2]]

  ;--Math Cheats
  dot = replicate(1,blksz)
  plus = findgen(blksz)

  ;--Expanded Superpixel index
  x = transpose(dot)##plus
  y = transpose(plus)##dot

  ;--Shift expanded index for each SUPERPIXEL!!
  FOR i=0,n-1 DO BEGIN
    xx = reform(x+(blocks[i,0]*blksz),blklen)
    yy = reform(y+(blocks[i,1]*blksz),blklen)

    missing[blklen*i:blklen*(i+1)-1]=long(yy*hdr.naxis1)+xx
  ENDFOR
ENDIF ELSE $

;-----------------------------------------

;--ICER Compression-----------------------
;IF hdr.COMPRSSN GT 89 THEN BEGIN

  ;--16 Segment ICER Compression----------
IF (hdr.COMPRSSN GE 96) AND (hdr.COMPRSSN LE 97) THEN BEGIN
    ;--Define Superpixel size and length   
    ax1=4 
    ax2=4
    blksz=long(hdr.naxis1/ax1)
   
   ;--Calculate the 2D index of the Superpixel
    blocks=[[misslist MOD ax1] ,[misslist/ax2]]

   ;--Calculate the Rectified 2D index!!
    IF hdr.RECTIFY EQ 'T' THEN BEGIN
      IF (hdr.OBSRVTRY EQ 'STEREO_A') THEN BEGIN
        CASE hdr.DETECTOR OF  
        'EUVI':blocks = [[ax1-blocks[*,1]-1],[ax1-blocks[*,0]-1]]
        'COR1':blocks = [[blocks[*,1]],[ax1-blocks[*,0]-1]]
        'COR2':blocks = [[ax1-blocks[*,1]-1],[blocks[*,0]]]
        'HI1' :blocks = blocks
        'HI2' :blocks = blocks
        ENDCASE
      ENDIF
      IF (hdr.OBSRVTRY EQ 'STEREO_B') THEN BEGIN
        CASE hdr.DETECTOR OF
        'EUVI':blocks = [[blocks[*,1]],[ax1-blocks[*,0]-1]]
        'COR1':blocks = [[ax1-blocks[*,1]-1],[blocks[*,0]]]
        'COR2':blocks = [[blocks[*,1]],[ax1-blocks[*,0]-1]]
        'HI1' :blocks = [[ax1-blocks[*,0]-1],[ax1-blocks[*,1]-1]]
        'HI2' :blocks = [[ax1-blocks[*,0]-1],[ax1-blocks[*,1]-1]]
        ENDCASE
      ENDIF
    ENDIF ELSE blocks=blocks

    ;--Buffer: add extra width to Superpixel 
    t=intarr(4,4)
    t[blocks[*,0],blocks[*,1]]=1
    buffer = intarr(4,4,4)
    buffer[0:2,*,0] = t[0:2,*]-t[1:*,*]>0
    buffer[1:*,*,1] = t[1:*,*]-t[0:2,*]>0
    buffer[*,0:2,2] = t[*,0:2]-t[*,1:*]>0
    buffer[*,1:*,3] = t[*,1:*]-t[*,0:2]>0
    buffer = reform(buffer,16,4)
    buffer = buffer[(blocks[*,1]*ax1+blocks[*,0]),*]

    ;--Define length of each block   
    blklen = replicate(blksz,n)
    blklen = (blklen+total(buffer[*,0:1],2,/int)*20L)*$
             (blklen+total(buffer[*,2:3],2,/int)*20L)
    missing = lonarr((total(blklen,/int)))

    ;--Math Cheats
    dot = replicate(1,blksz+40)
    plus = indgen(blksz+40)-20
 
    ;--Expanded Superpixel index
    x = transpose(dot)##plus
    y = transpose(plus)##dot

    ;--Shift expanded index for each SUPERPIXEL!!
    FOR i=0,n-1 DO BEGIN
      xx = x & yy = y
      IF ~buffer[i,0] THEN BEGIN&xx=xx[0:blksz+19,*]&yy=yy[0:blksz+19,*]&ENDIF
      IF ~buffer[i,1] THEN BEGIN&xx=xx[20:*,*] & yy =yy[20:*,*]&ENDIF 
      IF ~buffer[i,2] THEN BEGIN&xx=xx[*,0:blksz+19] &yy=yy[*,0:blksz+19]&ENDIF
      IF ~buffer[i,3] THEN BEGIN&xx=xx[*,20:*] & yy =yy[*,20:*]&ENDIF 

      xx = reform((xx+(blocks[i,0]*blksz)),blklen[i])
      yy = reform((yy+(blocks[i,1]*blksz)),blklen[i])
    missing[(total(blklen[0:i],/int)-blklen[i]):(total(blklen[0:i],/int)-1)]$
          =long(yy*hdr.naxis1)+xx
    ENDFOR
ENDIF ELSE $
  ;---------------------------------------

  ;--32 Segment ICER Compression----------
IF (hdr.COMPRSSN GE 90) AND (hdr.COMPRSSN LE 95) THEN BEGIN
   ;The 32 segment ICER compressions has four groups of different 
   ;sized rectangular superpixels. The groups are not on a regular grid.

    ;--Index of Supergroup
    sg = intarr(n)

    ;-- Define rectangular shaped Superpixels
    blksz = [[400,416,336,352],[320,320,384,384]]/2^(hdr.summed-1)
    ax1=[5,6]
    ax2=[4,2]

    ;--Supergroup offset from regular grid
    s = [[0,-32,0,-64],[0,0,-256,-256]]/2^(hdr.summed-1) 
  
    ;--Calculate the Supergroup index and 
    ;-- the 2D index of the Superpixels
    blocks = [[misslist],[misslist]]
   
    bot = where(misslist LE 19,botn)
    top = where(misslist GE 20,topn)

    IF topn GT 0 THEN BEGIN
      blocks[top,0] = (blocks[top,0]-20) MOD ax1[1]
      blocks[top,1] = ((blocks[top,1]-20)/ax1[1])+ ax2[0]

      three = where(blocks[top,0] GE 4,nthree)
      IF nthree GT 0 THEN sg[top[three]]=3
      two = where(blocks[top,0] LE 3,ntwo)
      IF ntwo GT 0 THEN sg[top[two]]=2
    ENDIF

    IF botn GT 0 THEN BEGIN 
      blocks[bot,0] = blocks[bot,0] MOD ax1[0]
      blocks[bot,1] = blocks[bot,1]/ax1[0]
  
      one = where(blocks[bot,0] GE 2,none)
      IF none GT 0 THEN sg[bot[one]]=1
      zero = where(blocks[bot,0] LE 1,nzero)
      IF nzero GT 0 THEN sg[bot[zero]]=0
     ENDIF

    ;--Buffer: add extra width to Superpixel 
    t=intarr(6,6)
    t[blocks[*,0],blocks[*,1]]=1
    t[[5,11,17,23]]=2
    buffer = intarr(6,6,4)
    buffer[0:4,*,0] = t[0:4,*]-t[1:*,*]>0
    buffer[1:*,*,1] = t[1:*,*]-t[0:4,*]>0
    buffer[*,0:4,2] = t[*,0:4]-t[*,1:*]>0
    buffer[*,1:*,3] = t[*,1:*]-t[*,0:4]>0

    c = where(t ne 2)
    buffer = reform(buffer,36,4)
    buffer = buffer[c,*]
    buffer = buffer[misslist,*]

   ;--Define length of each block   
    blklen=long64([[blksz[sg,0]],[blksz[sg,1]]])
    blklen = (blklen[*,0]+total(buffer[*,0:1],2,/int)*20L)*$
             (blklen[*,1]+total(buffer[*,2:3],2,/int)*20L)
    missing = lonarr((total(blklen,/int)),2)

    ;--Math Cheats
    dot = replicate(1,416+40) ;max of blksz
    plus = indgen(416+40)-20

    ;--Expanded Superpixel index
    x = transpose(dot)##plus
    y = transpose(plus)##dot

    ;--Loop over each Super-Superpixel
     FOR i=0,n-1 DO BEGIN
       xx = x[0:blksz[sg[i],0]+39,0:blksz[sg[i],1]+39]
       yy = y[0:blksz[sg[i],0]+39,0:blksz[sg[i],1]+39]

          IF ~buffer[i,0] THEN BEGIN
            xx=xx[0:blksz[sg[i],0]+19,*]&yy=yy[0:blksz[sg[i],0]+19,*]&ENDIF
          IF ~buffer[i,1] THEN BEGIN&xx=xx[20:*,*]&yy =yy[20:*,*]&ENDIF 
          IF ~buffer[i,2] THEN BEGIN
           xx=xx[*,0:blksz[sg[i],1]+19] &yy=yy[*,0:blksz[sg[i],1]+19]&ENDIF
          IF ~buffer[i,3] THEN BEGIN&xx=xx[*,20:*] & yy =yy[*,20:*]&ENDIF 
 
          xx = reform(xx+(blocks[i,0]*blksz[sg[i],0])+s[sg[i],0],blklen[i])
          yy = reform(yy+(blocks[i,1]*blksz[sg[i],1])+s[sg[i],1],blklen[i])

    missing[(total(blklen[0:i],/int)-blklen[i]):(total(blklen[0:i],/int)-1),*]$
          =[[xx],[yy]]
     ENDFOR

     ;--Calculate the Rectified 2D index!!
     IF hdr.RECTIFY EQ 'T' THEN BEGIN
       IF (hdr.OBSRVTRY EQ 'STEREO_A') THEN BEGIN
         CASE hdr.DETECTOR OF  
         'EUVI':missing = [[hdr.naxis1-missing[*,1]-1],[hdr.naxis1-missing[*,0]-1]]
         'COR1':missing = [[missing[*,1]],[hdr.naxis1-missing[*,0]-1]]
         'COR2':missing = [[hdr.naxis1-missing[*,1]-1],[missing[*,0]]]
         'HI1' :missing = missing
         'HI2' :missing = missing
         ENDCASE
       ENDIF
       IF (hdr.OBSRVTRY EQ 'STEREO_B') THEN BEGIN
         CASE hdr.DETECTOR OF
         'EUVI':missing = [[missing[*,1]],[hdr.naxis1-missing[*,0]-1]]
         'COR1':missing = [[hdr.naxis1-missing[*,1]-1],[missing[*,0]]]
         'COR2':missing = [[missing[*,1]],[hdr.naxis1-missing[*,0]-1]]
         'HI1' :missing = [[hdr.naxis1-missing[*,0]-1],[hdr.naxis1-missing[*,1]-1]]
         'HI2' :missing = [[hdr.naxis1-missing[*,0]-1],[hdr.naxis1-missing[*,1]-1]]
         ENDCASE
       ENDIF   
     ENDIF ELSE missing=missing

    missing = long(missing[*,1]*hdr.naxis1)+missing[*,0]
ENDIF ELSE $
IF hdr.comprssn GT 98 THEN BEGIN
;--1 Segment ICER Compression---------- (I'm assuming ICER 8-11 are 1 segment. -nr)
    IF hdr.nmissing GT 0 THEN missing=lindgen(float(hdr.naxis1)*hdr.naxis2) $
    ELSE missing=-1
ENDIF ELSE BEGIN
    message,'ICER8 (8-segment) compression not accomodated; returning -1',/info
    missing=-1
ENDELSE
; 
;ENDIF

IF ~keyword_set(SILENT) THEN print,systime(1)-tyme
RETURN, missing
END
