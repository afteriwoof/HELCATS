pro handle_draw_event, event, state, ishow

case event.type of
    7: begin                    ; Wheel events (advance & retreat)
        if state.play then return ; Ignore if playing

        if event.clicks gt 0 then $
          state.current = frame_find(state, -1) $
        else state.current = frame_find(state, 1)
        ishow = 1b
    end
    0: begin                    ; Press
        case event.press of
            4: begin            ; Right: quit or context
                if state.mark then begin
                    free_lun, state.lun
                    state.mark = 0b
                    widget_control, state.pbase, map = 1
                endif else widget_displaycontextmenu, event.id, $
                  event.x, event.y, state.cbase
            end
            2: if  state.mark then begin ; advance in mark mode only
                state.current = frame_find(state, 1)
                ishow = 1b
            endif else if (event.modifiers ne 0 and ~state.play and $
                           ~(*state.iscor)[state.current]) then begin
                x = event.x/state.scalef
                y = event.y/state.scalef
                get_secchi_coords, state, x, y, coord, elong, pa, epa
                make_secchi_section, state, pa
            endif
            1: if ~state.play then begin ; Left: mark
                x = event.x/state.scalef
                y = event.y/state.scalef
                get_secchi_coords, state, x, y, coord, elong, pa, epa

                val = (*state.data)[event.x, event.y, state.current]

                if state.mark then begin
                    printf, state.lun, (*state.dates)[state.current], x, $
                      y, coord, elong, pa, epa, val, format = $
                      "(A,2I5,5f9.3,g12.3)"
                    plots, event.x, event.y, /dev, ps = 1
                endif
                print, (*state.dates)[state.current], x, y, $
                  coord, elong, pa, epa, val, format = $
                  "(A,2I5,5f9.3,g12.3)"
            endif
        endcase
    end

    else:                       ; Ignore other types
endcase

end
