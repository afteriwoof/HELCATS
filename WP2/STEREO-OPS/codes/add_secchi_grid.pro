pro add_secchi_grid, state

;+
; ADD_SECCHI_GRID
;	Add a grid to a secchi image.
;
; Usage:
;	add_secchi_grid, state
;
; Argument:
;	state	struct	the "state" structure from show_secchi_data.
;
; History:
;	Original: 16/12/08; SJT
;
; Edited:
;	2014-11-27	to change the grid spacings and character settings. - Jason Byrne
;
;-

wcs = (*state.wcs)[state.current]
if (*state.iscor)[state.current] then sf = 3600. $
else sf = 1.
scalef = state.scalef

hdr = (*state.hdrs)[state.current]

if state.settings.grid eq 1 then begin   ; Lat and long.

    case strtrim(hdr.detector) of
        "COR1": begin
            step = 0.5
            min = -5.
            max = 5.
        end
        "COR2": begin
            step = 1.
            min = -10.
            max = 10.
        end
        "HI1": begin
            step = 2.
            min = -25.
            max = 25.
        end
        "HI2": begin
            step = 10. 
            min = -90.
            max = 90.
        end
    end


;   Longitude lines
    lat = findgen(1, 401)*(max/200.)+min
    for lon = min, max, step do begin
        loni = replicate(lon, 1, 401)
        coord = [loni, lat]*sf
        pxl = wcs_get_pixel(wcs, coord)*scalef
        plots, pxl, /dev
	xyouts, pxl[0,200]-(0.05*state.fsize[0]),pxl[1,200]+(0.02*state.fsize[1]),fix(lon),/dev
    endfor

;  Latitude lines
    lon = findgen(1, 401)*(max/200.)+min
    for lat = min, max, step do begin
        lati = replicate(lat, 1, 401)
        coord = [lon, lati]*sf
        pxl = wcs_get_pixel(wcs, coord)*scalef
        plots, pxl, /dev
	xyouts, pxl[0,20]-(0.02*state.fsize[0]),pxl[1,20]+(0.01*state.fsize[1]),fix(lat),/dev
    endfor

	; Plot line of ecliptic
        elon = findgen(1, 201)*max/200*!dtor
	dpa = (*state.tilt)[state.current]*!dtor
        case hdr.obsrvtry of
		"STEREO_A": pa = 90.
		"STEREO_B": pa = 270.
	endcase
        par = pa*!dtor-dpa
        lat = asin(cos(par)*sin(elon))
        lon = acos(cos(elon)/cos(lat))*!radeg
        if par lt !pi then lon = -lon
        lat =  lat*!radeg
        coord = [lon, lat]*sf
        pxl = wcs_get_pixel(wcs, coord)*scalef
        plots, pxl, /dev, line=2
	xyouts, 0, pxl[1,200], 'Ecliptic', /dev

endif else if state.settings.grid eq 2 or $
  state.settings.grid eq 3 then begin ; Elong & PA (3 is ecliptic pa)
    
    case strtrim(hdr.detector) of
        "COR1": begin
            step = 0.5
            max = 5.
        end
        "COR2": begin
            step = 1.
            max = 10.
        end
        "HI1": begin
            step = 2.
            max = 25.
        end
        "HI2": begin
            step = 10. 
            max = 90.
        end
    end

    if (*state.iscor)[state.current] then begin
        pamin = 0.
        pamax = 360.
        pastep = 20.
    endif else begin
        case hdr.obsrvtry of
            "STEREO_A": begin
                pamin = 0.
                pamax = 180.
            end
            "STEREO_B": begin
                pamin = 180.
                pamax = 360.
            end
        endcase
        pastep = 5.
    endelse

    if state.settings.grid eq 3 then dpa = $
      (*state.tilt)[state.current]*!dtor $
    else dpa = 0.0

; Elongation rings/arcs

    pa = (findgen(1, 361)*(pamax-pamin)/360. + pamin)*!dtor-dpa
    for elon = 0., max, step do begin
        elonr = elon*!dtor
        lat = asin(cos(pa)*sin(elonr))
        lon = acos(cos(elonr)/cos(lat))*!radeg
        locs = where(pa lt !pi, nl)
        if nl ne 0 then lon[locs] = -lon[locs]
        lat =  lat*!radeg
        coord = [lon, lat]*sf
        pxl = wcs_get_pixel(wcs, coord)*scalef
        plots, pxl, /dev
	xyouts, pxl[0,200]-(0.06*state.fsize[0]),pxl[1,200]+(0.02*state.fsize[1]),fix(elon),/dev
    endfor

; PA spokes

    elon = findgen(1, 201)*max/200*!dtor
    for pa = pamin, pamax, pastep do begin
        par = pa*!dtor-dpa
        lat = asin(cos(par)*sin(elon))
        lon = acos(cos(elon)/cos(lat))*!radeg
        if par lt !pi then lon = -lon
        lat =  lat*!radeg
        coord = [lon, lat]*sf
        pxl = wcs_get_pixel(wcs, coord)*scalef
        if pa eq 270 || pa eq 90 then plots, pxl, /dev, thick=3 else plots, pxl, /dev
        xyouts, pxl[0,195],pxl[1,195],fix(pa),/dev
	endfor
    ; Plot line of ecliptic
    if state.settings.grid ne 3 then begin
	dpa = (*state.tilt)[state.current]*!dtor
	pa = pamax/2
	par = pa*!dtor-dpa
	lat = asin(cos(par)*sin(elon))
        lon = acos(cos(elon)/cos(lat))*!radeg
        if par lt !pi then lon = -lon
        lat =  lat*!radeg
        coord = [lon, lat]*sf
        pxl = wcs_get_pixel(wcs, coord)*scalef
	plots, pxl, /dev, line=2
	epa = par*!radeg
	xyouts, 0+(0.01*state.fsize[0]), pxl[1,200]+(0.01*state.fsize[1]), 'Ecliptic PA: '+int2str(epa), /dev
endif
endif else print, "Bad grid code", state.settings.grid

end
