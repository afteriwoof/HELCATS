pro add_cor_occ, state

hdr = (*state.hdrs)[state.current]

arcs = hdr.cdelt1 ; plate scale (arcs/pixel), updated in secchi_prep
r_sun = hdr.rsun
r_sun = r_sun/arcs              ; radius of sun (pixels)
sunc = SCC_SUN_CENTER(hdr, FULL = 0)
r_occ = -1

case strtrim(hdr.detector) of
    "COR1": begin
        r_occ_out = r_sun*4.
        thick = 2
        xadj = 0.
        if strtrim(hdr.obsrvtry) eq 'STEREO_A' then begin
            yadj = r_sun/5.
            r_occ =  r_sun*1.55
        endif else begin
            yadj = 0.; r_sun/2.3
            r_occ = r_sun*1.55
        endelse
    end

    "COR2": begin
        thick = 3
        if strtrim(hdr.obsrvtry) eq 'STEREO_A' then begin
            yadj = 0.
            xadj = 0.
            r_occ =  r_sun*2.4
            r_occ_out = 1033
        endif else begin
            yadj = -r_sun/1.65
            xadj = r_sun/3.25
            r_occ = r_sun*2.6
            r_occ_out = 1035
        endelse
    end
endcase

scalef = state.scalef
window, /free, /pix, xs = state.fsize[0], ys = state.fsize[1]
pw = !d.window

erase, 255
tvcircle, r_occ_out*scalef, hdr.crpix1*scalef, hdr.crpix2*scalef, /fill, $
  col = 0
tvcircle, r_occ*scalef, (sunc.xcen+xadj)*scalef, $
  (sunc.ycen+yadj)*scalef, /fill, col = 255

im = tvrd()

wset, state.window
device, set_graphics_function = 7 ; source or dest
tv, im
im and= 128b
device, set_graphics_function = 4 ; not source and dest
tv, im
device, set_graphics_function = 3 ; source (normal plotting)

tvcircle, r_sun*scalef, sunc.xcen*scalef, sunc.ycen*scalef, thick = $
  thick, col = 255

im = tvrd()

wdelete, pw

return

end
