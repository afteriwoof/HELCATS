pro secchi_contours, image, hdrs, instr, img_pan,colour=colour

; +
; PRO SECCHI_CONTOURS
; ====================
;
; This program produces heliocentric latitude and longitude contours and
; elongation PA contours on the secchi HI and COR images.
; It then produces three eps files of the image(s) selected:
; One with no grid, one with a latitude/longitude grid, and one
; with a elongation/PA grid.
; The program is designed to be called in by the secchi_geometry
; routine.
;
; CREDIT
; ======
;
; Thanks to the secchi team as we have used some of the WSCC_MKMOVIE
; routine to produce the occulting disks for the CORs.
;
; KEYWORDS
; ==========
;
; IMAGE: FLTARR(1024,1024, N) - The image array input by secchi_geometry
; N is the number of images.
;
; HDRS: STRARR(N) The headers string array input by secchi_geometry
; N is the number of images.
;
; INSTR: STRING - A string label for the instrument used. 
; 'COR1-A', 'COR1-B', 'COR2-A', 'COR2-B', 'HI1-A', 'HI1-B', 'HI2-A', 'HI2-B'.
;
; IMG_PAN - FLOAT - A factor worked into the occulting disk routine to
; alter the size difference of the image. 
;
; COLOUR - KEYWORD - Activated if you want colour.
;
; PROGRAM HISTORY
; ================
;
; Written by T.A. Howard - December 2007. Original version worked 
; with HI data for an event in January 2007 and was entitled
; hi_contours_th.pro. It produced HI images and placed a grid over 
; the top, then plotted it to a ps file.
; Modified by T.A. Howard - January 2008. Created a version of
; hi_contours that could work with COR data. It was called
; cor_contours_th.pro.
; Modified by T.A. Howard - April 2008. Changed the program so it
; can access any data from any path. Now working with an event
; in November 2007.
; Modified by S.J. Tappin - April 2008. Combined the hi and cor
; routines and changed so it could be called in by secchi_geometry.
; Combined program changed to cor_contours_ths.pro
; Modified by T.A. Howard - April 2008. Added a few cosmetic details
; and changed the name to secchi_contours.pro.
; Modified by S.J. Tappin - April 2008. Fixed a bug involving the time
; stamps and creation of the eps filename.
;
; -
; BEGIN PROGRAM
; ==============

sz = size(image, /DIMENSIONS)
N_elem = 1
;window, 0, xsize=sz[0],ysize=sz[1]		; create the window

if n_elements(img_pan) eq 0 then img_pan=1.

arcs = hdrs.cdelt1 ; plate scale (arcs/pixel), updated in secchi_prep	
r_sun = hdrs.rsun*img_pan
r_sun = r_sun/arcs              ; radius of sun (pixels)
sunc = SCC_SUN_CENTER(hdrs,FULL=0)

date = string(strmid(hdrs.date_d$obs, [0,5,8,11,14], $
                     [4,2,2,2,2]),format="(3A,'_',2A)")

; Produce a plot to a PS file
set_plot, 'PS'
device, file=instr+'_'+date+'.eps', xsize=15,ysize=15, /encapsulate, $
  bits=8, color=colour
opx=!x
opy=!y

; Run the code to extract WCS data from the fits header, called FITSHEAD2WCS
WCS = FITSHEAD2WCS(hdrs)
; Turn the image pixels into coordinates using WCS_GET_COORD
if strmid(instr,0,3) eq 'COR' then coord = WCS_GET_COORD(WCS)/3600. $
else coord = WCS_GET_COORD(WCS)

datei = instr+' '+strmid(hdrs.date_d$obs,0,10)+' '+ $
  strmid(hdrs.date_d$obs,11,5) ; produce the date as a string element	
!x.margin=0
!y.margin=0

tvimage, image			; show the image

; Place time stamp
xyouts, 0.01,0.01, datei,charthick=2.0, charsize=2.0, /norm, color=255 

; !x=opx
; !y=opy

device, /close

; Now add the contours
device, file=instr+'_'+date+'_LL.eps', xsize=15,ysize=15, /encapsulate, $
  bits=8, color=colour
; opx=!x
; opy=!y

; Run the code to extract WCS data from the fits header, called FITSHEAD2WCS
WCS = FITSHEAD2WCS(hdrs)
; Turn the image pixels into coordinates using WCS_GET_COORD
if strmid(instr,0,3) eq 'COR' then coord = WCS_GET_COORD(WCS)/3600. $
else coord = WCS_GET_COORD(WCS)

datei = instr+' '+strmid(hdrs.date_d$obs,0,10)+' '+ $
  strmid(hdrs.date_d$obs,11,5) ; produce the date as a string element	
!x.margin=0
!y.margin=0
CONTOUR, coord[0,*,*],xsty=1,yst=1, /nodata

tvimage, image			; show the image


case hdrs.detector of
    'COR1': begin
        LEVELS = .5*findgen(21)-5.
    end
    'COR2': begin
        LEVELS = findgen(21)-10.
    end
    'HI1': begin
        LEVELS = 5*findgen(11)-25.
    end
    'HI2': begin
        LEVELS = 10*findgen(19)-90
    end
endcase
labels = replicate(1, n_elements(levels))

CONTOUR, coord[0,*,*], /OVERPLOT, LEVELS = levels , C_LABELS=labels, $
  C_CHARSIZE=1.0,C_COLORS=[255]
CONTOUR, coord[1,*,*], /OVERPLOT, LEVELS = levels, C_LABELS=labels, $
  C_CHARSIZE=1.0,C_COLORS=[255]

; Place time stamp
xyouts, 0.01,0.01, datei,charthick=2.0, charsize=2.0, /norm, color=255 

; !x=opx
; !y=opy

device, /close

device, file=instr+'_'+date+'_EP.eps', xsize=15,ysize=15, /encapsulate, $
  bits=8, color=colour

CONTOUR, coord[0,*,*],xsty=1,yst=1

tvimage, image			; show the image

; Determine the elongation and PA of the image
elongation = acos(cos(coord[0,*,*]*!Pi/180)*cos(coord[1,*,*]*!Pi/180))*180/!Pi
PA = 90-asin(sin(coord[1,*,*]*!dtor)/sin(elongation*!dtor))*!radeg

; Now plot the contours

case hdrs.detector of
    'COR1': begin
        elevels=.5*findgen(6)
        plevels=20.*findgen(10)
	plabels=0
    end
    'COR2': begin
        elevels=findgen(6)
        plevels=20*findgen(10)
	plabels=0
   end
    'HI1': begin
        elevels=5*findgen(6)
        plevels=10*findgen(19)
	if instr eq 'HI1-B' then plevels = 360.-reverse(plevels)
	plabels=replicate(1,n_elements(plevels))
	locs = where(coord[0,*,*] gt 0., np)
	if np ne 0 then pa[locs] = 360.-pa[locs]
    end
    'HI2': begin
        elevels=10*findgen(10)
        plevels=10*findgen(19)
	if instr eq 'HI2-B' then plevels = 360.-reverse(plevels)
	plabels=replicate(1,n_elements(plevels))
	locs = where(coord[0,*,*] gt 0., np)
	if np ne 0 then pa[locs] = 360.-pa[locs]
    end
endcase
elabels=replicate(1,n_elements(elevels))
plabels=replicate(1,n_elements(plevels))

CONTOUR, elongation, /OVERPLOT, LEVELS = elevels, C_LABELS=elabels, $
  C_CHARSIZE=1.0,C_COLORS=[255]
CONTOUR, PA, /OVERPLOT, LEVELS = plevels, C_LABELS=plabels, C_CHARSIZE=1.0, $
  C_COLORS=[255]

; Place time stamp
xyouts, 0.01, 0.01, datei,charthick=2.0, charsize=2.0, /norm, color=255 

device, /close

!x=opx
!y=opy

set_plot,'x'

end
