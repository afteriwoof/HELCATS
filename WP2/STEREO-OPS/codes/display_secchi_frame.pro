pro display_secchi_frame, state

;+
; DISPLAY_SECCHI_FRAME
;	Display the "current" frame of a secchi data block.
;
; Usage:
;	display_secchi_frame, state
;
; Argument:
;	state	struct	The "state" structure.
;
; Notes:
;	Designed to be called from show_secchi_data
;
; History:
;	Original: 15/12/08; SJT
;-

wset, state.window

icol = state.current/state.pmnrow
irow = state.current mod state.pmnrow

; print, state.current, icol, irow
; print, icol*state.fsize[0], irow*state.fsize[1], $
;                     state.fsize[0], state.fsize[1]

if (*state.imap)[state.current] then begin
    device, copy = [icol*state.fsize[0], irow*state.fsize[1], $
                    state.fsize[0], state.fsize[1], 0, 0, $
                    state.pixmap]
endif else begin
    hdr = (*state.hdrs)[state.current]
    dim = (*state.data)[*, *, state.current]
    bim = bytscl(dim, min = $
                 state.settings.range[0], max = $
                 state.settings.range[1], /nan)
     
    if (state.settings.krange[0] ne $
        state.settings.krange[1]) then begin
        locs = where(dim gt state.settings.krange[1] or $
                     dim lt state.settings.krange[0] or $
                     ~finite(dim), nkill)
        if nkill ne 0 then bim[locs] = 127b
    endif
    tv, bim
    if state.settings.grid ne 0 then add_secchi_grid, state
    if (*state.iscor)[state.current] then add_cor_occ, state

    if state.fsize[0] eq 256 then csize = 0.8 $
    else csize = 1.5
    xyouts, .02, .01, (*state.dates)[state.current], /norm, $
      charsize = csize
    xyouts, .98, .01, align = 1., strtrim(hdr.obsrvtry)+' '+ $
      strtrim(hdr.detector), /norm, charsize = csize


    wset, state.pixmap
    device, copy = [0, 0, state.fsize[0], state.fsize[1], $
                    icol*state.fsize[0], irow*state.fsize[1], $
                    state.window]
    (*state.imap)[state.current] = 1b
    wset, state.window
endelse

;if state.current eq state.nframes-1 then stop

end
