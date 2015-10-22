; Edited:
;	2014-11-27	- by Jason Byrne to save out the info on HI images when inspecting CMEs.
;-

pro sd_event, event

widget_control, event.top, get_uvalue = state
widget_control, event.id, get_uvalue = mnu

ishow = 0b
gflag = 0b
case mnu of
    'QUIT': begin
        ptr_free, state.data, state.hdrs, state.dates, state.jds, $ $
          state.imap, state.wcs, state.iscor, state.ihide, state.slon, $
          state.tilt

        wdelete, state.pixmap
        widget_control, event.top, /destroy 
        return                  ; by returning here we save
                                ; some conditions later on 
    end
    "MOVIE": if state.play  then begin
        state.current = frame_find(state)
        ishow = 1b
    endif

    "DRAW": handle_draw_event, event, state, ishow

    "MARK": begin
	; Set the filename to be that of the fts file in questions _pts.txt
	ofile = state.settings.savedir+'/'+strmid((*state.hdrs)[state.current].filename,0,strlen((*state.hdrs)[state.current].filename)-4)+'_pts.txt'
;	ofile = dialog_pickfile(dialog_parent = event.top, $
 ;                               filter = "*.txt", $
  ;                              /overwrite_prompt, $
   ;                             /write, $
    ;                            path = state.settings.savedir)
        if ofile ne "" then begin
            state.mark = 1b
            state.play = 0b
            widget_control, state.pbase, map = 0
            openw, ilu, /get, ofile
            printf, ilu, "   DATE       TIME        X    Y     Hlon     Hlat " + $
              "    Elong    H-PA     E-PA         Value" 
            state.lun = ilu
            state.settings.savedir = file_dirname(ofile)
        endif
    end

    "BACK": begin
        ishow = 1b
        state.direct = -1
        state.current = frame_find(state)
        state.play = 1b
        widget_control, state.pbase, map = 0
        widget_control, state.pid, set_value = "Pause"
    end

    "FORWARD": begin
        ishow = 1b
        state.direct = 1
        state.current = frame_find(state)
        state.play = 1b
        widget_control, state.pbase, map = 0
        widget_control, state.pid, set_value = "Pause"
    end

    "PREV": begin
        ishow = 1b
        state.current = frame_find(state, -1, /all)
    end

    "NEXT": begin
        ishow = 1b
        state.current = frame_find(state, 1, /all)
    end

    "SELECT": if event.value ne state.current then begin
        ishow = 1b
        state.current = event.value
    end

    "HIDE": begin
        (*state.ihide)[state.current] = ~(*state.ihide)[state.current]
        widget_control, state.hid, $
          set_value = (['Hide', $
                        'Unhide'])[(*state.ihide)[state.current]]
    end

    "GRAB": begin
        file = dialog_pickfile(dialog_parent = event.top, $
                               /overwrite_prompt, $
                               /write, $
                               filter = "*.png", $
                               path = state.settings.savedir)
        if file ne '' then begin
            im = tvrd(true = 1)
            write_png, file, im
            state.settings.savedir = file_dirname(file)
        endif
    end

    "GIF": make_secchi_gif, state

    "PAUSE": begin
        state.play = ~state.play
        widget_control, state.pbase, map = ~state.play
        widget_control, event.id, $
          set_value = (['Resume', 'Pause'])[state.play]
        widget_control, state.slid, set_value = state.current
    end

    "RANGE": begin
        ishow = 1b   
        set_secchi_range, state.settings.range, $
          state.settings.krange, event.top, range, krange, ich
        if ich then begin
            state.settings.range = range
            state.settings.krange = krange
            (*state.imap)[*] = 0b
        endif
    end

    "FAST": state.settings.delay /= 2.
    "SLOW": state.settings.delay *= 2

    "REVERSE": state.direct = -state.direct 
    "COLOUR": begin
        xloadct,  group = event.top
        (*state.imap)[*] = 0b
    end

    "GRID0": begin
        gflag = 1b
        state.settings.grid = 0
    end
    "GRID1": begin
        gflag = 1b
        state.settings.grid = 1
    end
    "GRID2": begin
        gflag = 1b
        state.settings.grid = 2
    end
    "GRID3": begin
        gflag = 1b
        state.settings.grid = 3
    end

endcase

if gflag then begin
    for j = 0, 3 do widget_control, state.gbids[j], sensitive = $
      state.settings.grid ne j
    ishow = 1b
    (*state.imap)[*] = 0b
endif

if ishow then begin
    display_secchi_frame, state
    if state.play then $
      widget_control, state.db, timer = state.settings.delay $
    else begin
        widget_control, state.slid, set_value = state.current
        widget_control, state.hid, $
          set_value = (['Hide', $
                        'Unhide'])[(*state.ihide)[state.current]]
    endelse
endif

locs = where(~(*state.imap), nnm)
widget_control, state.mid, sensitive = nnm eq 0
widget_control, event.top, set_uvalue = state

end

pro secchi_show, data, hdrs, settings

;+
; SECCHI_SHOW
;	Displays SECCHI data.
;
; Usage:
;	secchi_show, data, hdrs, settings
; or:
; 	secchi_show
;
; Arguments:
;	data	float	The images to show.
;	hdrs	struct	The image headers
;	settings struct	The display options.
;
; History:
;	Original: 15/12/08; SJT
;-

common sci_proc_data, ddata, phdrs, dsettings

if n_params() eq 0 then begin   ; Use previous data from common
    if n_elements(ddata) eq 0 then begin
        print, "No processed data found, please use SECCHI_DISPLAY"
        return
    endif
    data = ddata
    hdrs = phdrs
    settings = dsettings
endif else begin                ; Store data in common
    ddata = data
    phdrs = hdrs
    dsettings = settings
endelse


sz = size(data, /dim)
nframes = sz[2]
hoff = n_elements(hdrs)-nframes
scalef = float(sz[0])/float(hdrs[0].naxis1)
r2 = sz[0] le 256

; Sort out dates & WCS
datest = strarr(nframes)
jds = dblarr(nframes)

tmpl = fitshead2wcs(hdrs[hoff])
wcs = replicate(tmpl, nframes)
iscor = bytarr(nframes)

slon = fltarr(nframes)
tilt = fltarr(nframes)
an = 75.879                     ; Longitude of the ascending node
tilt0 = 7.25                    ; Inclination of the solar axis to
tt0 = tan(tilt0*!dtor)          ; ecliptic

for j = 0, nframes-1 do begin
    da = strsplit(hdrs[j+hoff].date_d$obs, '-:T', /extract) ; Average
                                ; date of frame
    jds[j] = julday(float(da[1]), float(da[2]), float(da[0]), $
                    float(da[3]), float(da[4]), float(da[5]))
    datest[j] = da[0]+'/'+da[1]+'/'+da[2]+' ' + $
      ''+da[3]+':'+da[4]+':'+da[5]
    sunpos,  jds[j], ra, dec, elon
    dlon = atan(hdrs[j+hoff].heey_obs, hdrs[j+hoff].heex_obs)*!radeg
    slon[j] = elon+dlon
    tilt[j] = atan(-tt0*cos((slon[j]-an)*!dtor))*!radeg
    struct_assign, fitshead2wcs(hdrs[j+hoff]), tmpl, /verb
    wcs[j] = tmpl
    iscor[j] = strmid(hdrs[j+hoff].detector, 0, 1) eq 'C'
endfor

; Determine dimensions of storage pixmap.

maxcol = floor(32000./sz[1])
ncol = nframes/maxcol
if nframes mod maxcol ne 0 then ncol++

nrow = maxcol < nframes
window, /free, /pixmap, xsize = ncol*sz[0], ysize = nrow*sz[1]
ipixmap = !d.window

; Set up the GUI

device, get_screen_size = screen_sz

base = widget_base(title = 'Secchi data', $
                   /column)

iscroll = 0b
xsize = sz[0]
ysize = sz[1]

if sz[0] gt 0.9*screen_sz[0] then begin
    iscroll = 1b
    xsize = round(0.9*screen_sz[0])
endif
if sz[1] gt 0.8*screen_sz[1] then begin
    iscroll = 1b
    ysize = round(0.8*screen_sz[1])
endif

db = widget_base(base, $
                 uvalue = "MOVIE")

if iscroll then $
  draw = widget_draw(db, $
                     xsize = sz[0], $
                     ysize = sz[0], $
                     x_scroll_size = xsize, $
                     y_scroll_size = ysize, $
                     /scroll, $
                     /button_events, $
                     /wheel_events, $
                     uvalue = 'DRAW') $
else $
  draw = widget_draw(db, $
                     xsize = xsize, $
                     ysize = ysize, $
                     /button_events, $
                     /wheel_events, $
                     uvalue = 'DRAW')


; Controls to display under the window when paused.

if r2 then begin         ; This little trick lets us do 2 rows for 256
                                ; square 
    pbase = widget_base(base, $
                        /col, $
                        map = 0)
    pb0 = widget_base(pbase, $
                      /row)
    pb1 = widget_base(pbase, $
                      /row)
endif else begin
    pbase = widget_base(base, $
                        /row, $
                        map = 0)
    pb0 = pbase
    pb1 = pbase
endelse


junk = widget_button(pb1, $
                     value = "Mark Points", $
                     uvalue = "MARK")

junk = widget_button(pb0, $
                     value = "<<", $
                     uvalue = "BACK")

junk = widget_button(pb0, $
                     value = "<", $
                     uvalue = "PREV")

slid = widget_slider(pb0, $
                     max = nframes-1, $
                     uvalue = "SELECT", $
                     /drag)

junk = widget_button(pb0, $
                     value = '>', $
                     uvalue = "NEXT")

junk = widget_button(pb0, $
                     value = ">>", $
                     uvalue = "FORWARD")

hid = widget_button(pb1, $
                    value = " Hide ", $
                    uvalue = "HIDE")

junk = widget_button(pb1, $
                     value = "Capture", $
                     uvalue = "GRAB")

mid = widget_button(pb1, $
                    value = "Gif", $
                    uvalue = "GIF")
widget_control, mid, sensitive = 0

junk = widget_button(pb1, $
                     value = 'Quit', $
                     uvalue = 'QUIT')

; Pop-up to show on right click

cbase = widget_base(draw, $
                    /context_menu)

pid = widget_button(cbase, $
                    value = "Pause ", $
                    uvalue = "PAUSE")
junk = widget_button(cbase, $
                     value = "Faster", $
                     uvalue = "FAST")
junk = widget_button(cbase, $
                     value = "Slower", $
                     uvalue = "SLOW")
junk = widget_button(cbase, $
                     value = "Reverse", $
                     uvalue = "REVERSE")

junk = widget_button(cbase, $
                     value = "Data range", $
                     uvalue = "RANGE")

junk = widget_button(cbase, $
                     value = "Colour table", $
                     uvalue = "COLOUR")

junk = widget_button(cbase, $
                     value = "Grid", $
                     /menu)
gbids = lonarr(4)
gbids[0] = widget_button(junk, $
                         value = "None", $
                         uvalue = "GRID0")
gbids[1] = widget_button(junk, $
                         value = "Lat & Lon", $
                         uvalue = "GRID1")
gbids[2] = widget_button(junk, $
                         value = "Elong & H-PA", $
                         uvalue = "GRID2")
gbids[3] = widget_button(junk, $
                         value = "Elong & E-PA", $
                         uvalue = "GRID3")
widget_control, gbids[settings.grid], sensitive = 0

junk = widget_button(cbase, $
                     value = 'Quit', $
                     uvalue = 'QUIT')


widget_control, base, /realize
widget_control, draw, get_value = iwin

state = {secchi_state, $
         data: ptr_new(data), $
         hdrs: ptr_new(hdrs[hoff:*]), $
         wcs: ptr_new(wcs), $
         slon: ptr_new(slon), $
         tilt: ptr_new(tilt), $
         iscor: ptr_new(iscor), $
         nframes: nframes, $
         fsize: sz[0:1], $
         scalef: scalef, $
         current: 0, $
         direct: 1, $
         dates: ptr_new(datest), $
         jds: ptr_new(jds), $
         settings: settings, $
         window: iwin, $
         pixmap: ipixmap, $
         pmncol: ncol, $
         pmnrow: nrow, $
         imap: ptr_new(bytarr(nframes)), $
         ihide: ptr_new(bytarr(nframes)), $
         lun: 0l, $
         mark: 0b, $
         play: 1b, $
         db: db, $
         draw: draw, $
         pbase: pbase, $
         slid: slid, $
         hid: hid, $
         mid: mid, $
         cbase: cbase, $
         pid: pid, $
         gbids:gbids}

widget_control, base, set_uvalue = state

display_secchi_frame, state
widget_control, db, timer = settings.delay

xmanager, 'sd', base;, /no_block

end

