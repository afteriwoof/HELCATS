pro secchi_geometry, hi, range=range, delta=delta,median=median, $
                         delay=delay,select=select, shift=shift, $
                         measure=measure,ps=ps,colour=colour

;+
; PRO SECCHI_GEOMETRY
; =====================
;
; This program inputs a series of STEREO SECCHI images and then
; performs the following:
; 1. Show a quicklook movie
; 2. Make measurements of any pixel and convert to heliographic
; latitude & longitude, and elongation & position angle.
; 3. Output a txt file with the measurements.
;
; PRIOR TO RUNNING THIS PROGRAM
; =============================
;
; 1. Separate the raw images into meaningful categories (eng vs img),
; d4 vs n4, etc.
; 2. Pass the appropriate images through SECCHI_PREP.
; 3. Put the prepped images in an appropriate directory.
; 4. Change the directory in the code below to match the one with
; the data. This is located in the string array 'FILENAME'.
; 5. Open the terminal in the same directory as that where you want
; to put the output text file.
;
; KEYWORDS
; ==========
;
; HI: STRING - The instrument:
;				'H1A' = HI1-A, 'H1B' = HI1-B
;				'H2A' = HI2-A, 'H2B' = HI2-B
;				'C1A' = COR1-A, 'C1B' = COR1-B
;				'C2A' = COR2-A, 'C2B' = COR2-B
;
; RANGE: FLOAT or [FLOAT, FLOAT] - The max and min limits for the image.
;				If keyword is set to a single number x then the range is set to [-x,+x].
;				Otherwise range is entered in [x,y] format.
;				Default is [-1.,1.].
;				Recommended starting point: 
;				1 for the HIs,
;				5E-9 for COR1,
;				2E-11 for COR2.
;
; DELTA: INTEGER - The increment for the running difference.
;				e.g. if DELTA is set to 2 then the (x-2)th
;				image is subtracted from
;				image x.
;				Default is 1 (i.e. standard running difference).
;
; MEDIAN: INTEGER - The number of surrounding pixels for the median smoothing function.
;				If set to 0 or 1 then no median is performed.
;				Recommended starting point: 5
;
; DELAY: FLOAT - The time delay between images for the movie in seconds.
;
; SELECT: 2 ELEMENT ARRAY [x:y] (y > x) - The images you want to look at.
;				Useful if you have a directory with a large number of images and not
;				enough computer memory to process them all.
;
; SHIFT: INTEGER - The number of pixels you wish to move the prior image before subtraction.
;				Useful for star subtraction with the HIs (particularly HI2).
;				Recommended starting point: +1 for HI2.
;
; /MEASURE: KEYWORD - Activates the measuring tool.
; 				Do not include if you only want to view	 the movie.
;
; /PS: KEYWORD - Activates the postscript generation tool. This includes an option to add a grid.
;				This overrides the /MEASURE keyword so if both are selected the code will
;				only do the /PS function.
;
; /COLOUR: KEYWORD - Adds colour to the images. Colours are predetermined as follows:
;					COR1-A: Green
;					COR1-B: Green
;					COR2-A: Red
;					COR2-B: Blue
;					HI1-A: Red
;					HI1-B: Blue
;					HI2-A: Red
;					HI2-B: Blue
;
; EXAMPLE
; ========
;
; secchi_geometry, 'H2b',median=5,shift=1,range=1.0,delay = 1.0, /measure
;
; Produces a HI2-B movie with a median smoothing function of 5 surrounding
; pixels. It is a running difference image (delta = 1 by default), and the previous
; image is shifted to the right by one pixel to aid in star removal.
; The movie is shown with an image (delay) every 1 second and when the movie 
; is concluded the measuring tool is activated.
;
; secchi_geometry, 'H2b',median=5,shift=1,range=1.0,delay = 1.0, /ps, /col
; Does the same processing but produces postscript files in colour. The generated
; image takes the form: 
; yyyymmdd_hhmm.eps for no grid,
; yyyymmdd_hhmm_LL.eps for the heliocentric latitude/longitude grid
; yyyymmdd_hhmm_EP.eps for the elongation/position angle grid
;
; PROGRAM HISTORY
; ================
;
; Written by T.A. Howard - December 2007. Original version worked
; with HI data for an event in January 2007.
; Originally called secchi_geometry_th.pro
; Modified by T.A. Howard - March 2008. Changed to work with an
; event in November 2007 and added COR data.
; Modified by S.J. Tappin - April 2008. Tidied up code to make more
; efficient and added header features.
; Name changed to secchi_geometry_ths.pro
; Modified by T.A. Howard - April 2008. Added preamble and occulting
; disk to  COR images.
; Modified by S.J. Tappin - April 2008. Added call in to secchi_contours
; routine allowing the code to produce postscript files and to add colours
; and a grid.
; Modified by T.A. Howard - April 2008. Tidied up code and added a few
; cosmetic features.
; Name changed to secchi_geometry.pro
;
;-
; BEGIN PROGRAM
; ==============
;
;  Load the images. 
; Change the text in this string array to the location of your data
filename=strarr(4)
case strupcase(hi) of
    'H1A': begin
        filename = '/home/thoward/data/STEREO_NOV2007/HI_1A/prepped'
        instr = 'HI-1A'
        ct=3
    end
    'H1B': begin
        filename = '/home/thoward/data/STEREO_NOV2007/HI_1B/prepped'
        instr = 'HI-1B'
        ct=1
    end
    'H2A': begin 
        filename = '/home/thoward/data/STEREO_NOV2007/HI_2A/prepped'
        instr = 'HI-2A'
        ct=3
    end
    'H2B': begin 
        filename = '/home/thoward/data/STEREO_NOV2007/HI_2B/prepped'
        instr = 'HI-2B'
        ct=1
    end
    'C1A': begin 
        filename = '/home/thoward/data/STEREO_NOV2007/COR_1A/prepped'
        instr = 'COR1-A'
        ct=8
    end
    'C1B': begin
        filename = '/home/thoward/data/STEREO_NOV2007/COR_1B/prepped'
        instr = 'COR1-B'
        ct=8
    end
    'C2A': begin 
        filename = '/home/thoward/data/STEREO_NOV2007/COR_2A/prepped_d4'
        instr = 'COR2-A'
        ct=3
    end
    'C2B': begin
        filename = '/home/thoward/data/STEREO_NOV2007/COR_2B/prepped_d4'
        instr = 'COR2-B'
        ct=1
    end
endcase

; change the units from arcseconds to degrees if using the CORs.
iscor =strmid(strupcase(hi),0,1) eq 'C'
ccf=([1.,1./3600.])[iscor]

; enter the range or default range
if ~keyword_set(range) then range=[-1.,1.] $
else if n_elements(range) eq 1 then range=[-range, range]

; enter the other defaults as required
if n_elements(delta) eq 0 then delta=1
if ~keyword_set(median) then median = 0
if ~keyword_set(delay) then delay=0.
if ~keyword_set(shift) then shift=0

a=file_list(filename)      ; lists all the available fits files in the
                                ; directory filename[0] in the variable "a"
; If "select" keyword is set then limit the files to those chosen.
; Otherwise keep the entire selection.
if keyword_set(select) then $
  mreadfits,a[select[0]:select[1]], hdrs, data_cube $
else mreadfits,a,hdrs,data_cube ; reads in the fits files and
                                ; stores the image data in "data_cube"
sz = size(data_cube, /DIMENSIONS)
N_elem = sz[2]

nframes=n_elem-delta
bdata = bytarr(sz[0],sz[1],n_elem-delta)
date=strarr(n_elem-delta)

hdrd=hdrs[delta:*]

; process the data. do the median and shift if required
for i = delta, N_elem-1 do begin
    if delta eq 0 then begin
        if median gt 1 then $
          bdata[*,*,i]=bytscl(median(data_cube[*,*,i], median), $
                                    min=range[0],max=range[1]) $
        else  bdata[*,*,i]=bytscl(data_cube[*,*,i], $
                                        min=range[0],max=range[1])
    endif else begin
        if median gt 1 then $
          bdata[*,*,i-delta]=bytscl(median(data_cube[*,*,i]- $
                                           shift(data_cube[*,*,i-delta], $
                                                 shift,0), $
                                           median),min=range[0],max=range[1]) $
        else  bdata[*,*,i-delta]=bytscl(data_cube[*,*,i]- $
                                        shift(data_cube[*,*,i-delta], $
                                              shift,0), $
                                        min=range[0],max=range[1])
    endelse
    date[i-delta] = instr+' '+ $
      strmid(hdrs[i].date_d$obs,0,10)+' '+ $
      strmid(hdrs[i].date_d$obs,11,5)
    print, i, n_elem-1, string(13b), format="(I3,'/',I3,a,$)"
endfor

; prompt for the the movie
ans1 = ' ' & ans2=' ' & ans3=' '
Use = intarr(N_elem)
Print, 'Ready for the movie (y/n)? '
read, ans1
if ans1 eq 'y' then begin
    fillcol=127
    if sz[0] le 1024 then begin
        window, 0, xsize=sz[0],ysize=sz[1] ; decide on the window size.
                                ; for 1024x1024 images, do them to size
        img_pan=1.0
    endif else begin
        window, 0, xsize=sz[0]/2,ysize=sz[1]/2 ; for 2048x2048 images (COR2),
                                ; scale them down by a factor of 2.
        img_pan=0.5
    endelse

    ; if colour keyword is set, then bring it up.
    if keyword_set(colour) then loadct,ct

    repeat begin
        for i = 0, nframes-1 do begin
            tbdata=bdata[*,*,i]
                                ; set up the parameters for the COR occulter
            if iscor then begin
                arcs = hdrd[i].cdelt1 ; plate scale (arcs/pixel), updated in secchi_prep	
                r_sun = hdrd[i].rsun
                r_sun = r_sun/arcs ; radius of sun (pixels)
                sunc = SCC_SUN_CENTER(hdrd[i],FULL=0)
                r_occ=-1
                CASE STRLOWCASE(hdrd[i].detector) OF
                    'cor1' : begin 
                        r_occ=r_sun * 1.2
                        r_occ_out = r_sun * 4.0
                        linethickness = 2
                        if strupcase(hi) eq 'C1A' then begin
                            xadj=0.
                            yadj=(r_sun/5.0)
                            r_occ=r_sun * 1.55
                        endif else $
                          if strupcase(hi) eq 'C1B' then begin
                            xadj=0
                            yadj=(r_sun/2.3)
                            r_occ=r_sun * 1.55
                        endif
                    end
                    'cor2' : begin 
                        img_pan=0.5
                        linethickness = 3
                        if strupcase(hi) eq 'C2B' then begin
                            r_occ=r_sun * 2.4
                            r_occ_out = 1035
                            xadj=(r_sun/3.25)
                            yadj=(r_sun/1.65)
                        endif else begin
                            r_occ=r_sun * 2.6
                            r_occ_out = 1033
                            xadj=0.0 
                            yadj=0.0
                        endelse
                    end
                ENDCASE
                if i eq 0 then begin
                    window,/free,/pix,xs=sz[0],ys=sz[1]
                    TVCIRCLE, r_occ_out,hdrd[0].crpix1,hdrd[0].crpix2, $
                      /FILL, COLOR=1
                    tmp_img = TVRD()
                    ind1 = WHERE(tmp_img EQ 0, nind1)
                    erase, 0
                    TVCIRCLE, r_occ, sunc.xcen+xadj, sunc.ycen-yadj, $
                      /FILL, COLOR=1
                    tmp_img = TVRD()
                    ind2 = WHERE(tmp_img ne 0, nind2)
                    erase, 0
                    TVCIRCLE, r_sun, sunc.xcen, sunc.ycen, COLOR=1, $
                      THICK=linethickness
                    tmp_img = TVRD()
                    ind3 = WHERE(tmp_img ne 0, nind3)
                    wdelete
                endif
                if nind1 ne 0 then tbdata[ind1]=fillcol
                if nind2 ne 0 then tbdata[ind2]=fillcol
                if nind3 ne 0 then tbdata[ind3]=255b
                bdata[*,*,i] = tbdata
            endif
                                ; draw the image
            tvimage, tbdata
                                ; add COR occulter
            if iscor then begin
            endif
                                ; place time stamp
            xyouts, 10,10, date[i],charthick=1.0, charsize=2.0, /DEVICE 
                                ; delay before showing next frame
            wait,delay
        endfor
        print, 'Again (y/n)? '  ; wanna see the flick again?
        read, ans2
    endrep until ans2 eq 'n'
endif

if ~keyword_set(measure)  && ~keyword_set(ps) then return

; Which frames do you want to see?
fflag=0b
repeat begin
    Print, 'Which image would you like to see (', $
      string(0,nframes-1, format="(I0,'-',I0)"), ') (-1 to exit)? '
    read, ii
    if ii lt 0 then break
    if sz[0] le 1024 then window, 0, xsize=sz[0],ysize=sz[1] $
    else window, 0, xsize=sz[0]/2,ysize=sz[1]/2
    
    tvimage,bdata[*,*,ii]
    xyouts, 10,10, date[ii],charthick=1.0,charsize=2.0, /DEVICE ; time stamp
    Print, 'Use it (y/n)? '     ; keep the image?
    read, ans3
    if ans3 eq 'y' then begin
        Use[ii] = 1 ; add the image as an index to the array "Use" for later
        fflag=1b
    endif
endrep until ii eq 0
if ~fflag then return

sjt = where(Use eq 1) ; create an array of indices of the images you want to use

; Measure the points on the images
; Here we use the command CURSOR to measure the coordinates of the
; image and convert them to real values
for i = 0, n_elements(sjt)-1 do begin
    if i eq 0 then print, 'Press any key to do the first image.' $
    else print, 'Press any key to do the next image.'
    junk=get_kbrd()
    if sz[0] le 1024 then window, 0, xsize=sz[0],ysize=sz[1] $
    else window, 0, xsize=sz[0]/2,ysize=sz[1]/2

    tvimage, bdata[*,*,sjt[i]]
    xyouts, 10,10, date[sjt[i]],charthick=1.0,charsize=2.0, $
      /DEVICE                   ; time stamp
    sflag = 1B
    if keyword_set(ps) then begin
;        stop
        secchi_contours, bdata[*,*,sjt[i]], hdrd[sjt[i]], $
          instr, img_pan, colour=colour
    endif else begin
        while 1 do begin
            CURSOR, X, Y, /NORMAL, /DOWN ; measure the point and
                                ; assign its coords to X and Y (normalized,
                                ; i.e. between 0 & 1)
            if !MOUSE.button EQ 4 then break ; pull out of the loop if
                                ; you hit the right mouse button
            plots, X,Y, psym=1, /NORMAL ; add a + to the point on the
                                ; image you've just measured
            if sflag then begin
                XA = X ; create an array XA containing the first X value
                YA = Y ; create an array YA containing the first Y value
                sflag = 0B
            endif else begin
                XA = [XA,X] ; each measurement thereafter increases the array X (Y)
                YA = [YA,Y] ; size by 1 and adds the new X (Y) measurement
            endelse
        endwhile
        XA*=sz[0]    ; Convert the normalized X pixels to image pixels
                                ; (i.e. between 0 and 1023)
        YA*=sz[1]    ; Convert the normalized Y pixels to image pixels
                                ; (i.e. between 0 and 1023)

                                ; Turn the image pixels into coordinates
                                ; using WCS_GET_COORD
        WCS = FITSHEAD2WCS(hdrd[sjt[i]])
        coord = fltarr(2,n_elements(XA))
        for j = 0, n_elements(XA)-1 do coord[*,j] = $
          WCS_GET_COORD(WCS, [XA[j],YA[j]])*ccf
                                ; So now we have a 2 vector array "coord"
                                ; containing heliographic longitude in the first
                                ; vector (coord[0]) & latitude in the second
                                ; (coord[1])
                                ; Create arrays for latitude, longitude,
                                ; elongation and PA
                                ;latitude = fltarr(n_elements(XA)) & longitude
                                ;= fltarr(n_elements(XA))
                                ;elongation = fltarr(n_elements(XA)) & PA =
                                ;fltarr(n_elements(XA))
                                ; Assign values to latitude and longitude
        latitude = REFORM(coord[1,*]) 
        longitude = REFORM(coord[0,*])
                                ; Calculate elongation and PA for each measured point
        elongation = acos(cos(REFORM(coord[0,*])*!Pi/180)* $
                          cos(REFORM(coord[1,*])*!Pi/180))*180/!Pi
        PA = 90-asin(sin(latitude*!dtor)/sin(elongation*!dtor))*!radeg
        locs=where(longitude gt 0., np)
        if np ne 0 then pa[locs]=360.-pa[locs]

                                ; Print the measurements
        P_filename = strupcase(hi)+ $
          strmid(hdrd[sjt[i]].date_d$obs,0,4)+ $
          strmid(hdrd[sjt[i]].date_d$obs,5,2)+ $
          strmid(hdrd[sjt[i]].date_d$obs,8,2)+'_'+ $
          strmid(hdrd[sjt[i]].date_d$obs,11,2)$
          +strmid(hdrd[sjt[i]].date_d$obs,14,2)+ $
          strmid(hdrd[sjt[i]].date_d$obs,17,2)
        OpenW, u, P_filename+'.txt', /GET_LUN
        for j = 0, n_elements(XA)-1 do printF, u, $
          format = '(A,1x,I4,1x,I4,1x,4(F7.3,1x))' ,$
          date[sjt[i]]+':'+strmid(hdrd[sjt[i]].date_d$obs,17,2),XA[j],YA[j], $
          latitude[j],longitude[j],elongation[j],PA[j]
        FREE_LUN, u
    endelse
endfor

end
