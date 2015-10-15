pro srange_event, event

common scci_rng, nrange, nkrange, flag

widget_control, event.id, get_uvalue = mnu

case mnu of
    "QUIT": begin
        if event.value eq 'DONT' then flag = 0b $
        else flag = 1b
        widget_control, event.top, /destroy
    end

    "MIN": nrange[0] = event.value
    "MAX": nrange[1] = event.value
    "KMIN": nkrange[0] = event.value
    "KMAX": nkrange[1] = event.value
endcase

end

pro set_secchi_range, range, krange, group, orange, okrange, ich

common scci_rng, nrange, nkrange, flag

nrange = range
nkrange = krange

base = widget_base(group = group, $
                   title = "Set ranges", $
                   /column, $
                   /modal)

jb = widget_base(base, $
                 /row)
junk = cw_ffield(jb, $
                 label = "Data range: Min", $
                 /float, $
                 value = range[0], $
                 format = "(G11.3)", $
                 uvalue = "MIN", $
                 xsize = 12)

junk = cw_ffield(jb, $
                 label = "Max", $
                 /float, $
                 value = range[1], $
                 format = "(G11.3)", $
                 uvalue = "MAX", $
                 xsize = 12)

jb = widget_base(base, $
                 /row)
junk = cw_ffield(jb, $
                 label = "Kill range: Min", $
                 /float, $
                 value = krange[0], $
                 format = "(G11.3)", $
                 uvalue = "KMIN", $
                 xsize = 12)

junk = cw_ffield(jb, $
                 label = "Max", $
                 /float, $
                 value = krange[1], $
                 format = "(G11.3)", $
                 uvalue = "KMAX", $
                 xsize = 12)

jjunk = cw_bgroup(base, $
                  ['Apply', 'Cancel'], $
                  button_uvalue = ['DO', 'DONT'], $
                  /row, $
                  uvalue = "QUIT")

widget_control, base, /real
xmanager, 'srange', base

if flag then begin
    orange = nrange
    okrange = nkrange
endif
ich = flag

end
