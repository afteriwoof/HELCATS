function frame_find, state, direct, all = all

if n_params() eq 1 then direct = state.direct

curr = state.current

if keyword_set(all) then begin
    curr += direct 
    if curr ge state.nframes then curr = 0
    if curr lt 0 then curr = state.nframes-1
endif else begin
    hidden = *state.ihide
    repeat begin
        curr += direct 
        if curr ge state.nframes then curr = 0
        if curr lt 0 then curr = state.nframes-1
    endrep until ~hidden[curr]
endelse

return, curr

end
