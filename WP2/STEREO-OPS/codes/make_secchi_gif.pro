pro make_secchi_gif, state

;+
; MAKE_SECCHI_GIF
;	Create an animated gif of a secchi sequence.
;
; Usage:
;	make_secchi_gif, state
;
; Argument:
;	state	struct	The "state" structure.
;
;
; History:
;	Original (after display_secchi_frame): 6/11/09; SJT
;-

imap = *state.imap
locs = where(~imap, nnm)
if nnm ne 0 then begin
    junk = dialog_message(["Must have all the frames images", $
                           "generated to make a gif"], $
                          /error)
    return
endif

gfile = dialog_pickfile(/write, $
                        /overwrite, $
                        filter = "*.gif")
if gfile eq '' then return

wset, state.pixmap

for j = 0, state.nframes-1 do begin
    icol = j/state.pmnrow
    irow = j mod state.pmnrow

    im = tvrd(icol*state.fsize[0], irow*state.fsize[1], $
                    state.fsize[0], state.fsize[1])

    write_gif, gfile, im, /multiple, delay = 10, repeat = 0
endfor
write_gif, /close
wset, state.window

;if state.current eq state.nframes-1 then stop

end
