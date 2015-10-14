pro make_secchi_section, state, pa

sfile = dialog_pickfile(dialog_parent = state.draw, $
                        filter = "*.sav*", $
                        title = "Save file for section", $
                        /overwrite_prompt)

if sfile eq '' then return      ; Cancel

state.settings.savedir = file_dirname(sfile)

print, pa

scalef = state.scalef
x = indgen(state.fsize[0]);*scalef
wcs = (*state.wcs)[state.current] ; We're being lazy here and just
                                ; using the track in the current frame.

hdr = (*state.hdrs)[state.current]

case strtrim(hdr.detector) of
    "HI1":max = 25.
    "HI2": max = 100.
end

elon = findgen(1, 201)*max/200*!dtor
par = pa*!dtor
 
lat = asin(cos(par)*sin(elon))
lon = acos(cos(elon)/cos(lat))*!radeg
if par lt !pi then lon = -lon
lat =  lat*!radeg
coord = [lon, lat]
pxl = wcs_get_pixel(wcs, coord)*scalef
plots, pxl, /dev


xt = reform(pxl[0, *])
yt = reform(pxl[1, *])

y = interpol(yt, xt, x)

locs = where(y ge 0 and y le state.fsize[1], nsect)

if nsect eq 0 then return

x = x[locs]
y = y[locs]

sect = fltarr(state.nframes, nsect)

data = *state.data

for j = 0, state.nframes-1 do begin
    tmp = data[*, *, j]
    sect[j, *] = tmp[x, y]
endfor
jds = *state.jds

elons = fltarr(nsect)
for j = 0, nsect-1 do begin
    xx = x[j]/scalef
    yy = y[j]/scalef
    get_secchi_coords, state, xx, yy, coord, elon, pa, epa
    elons[j] = elon
endfor

save, file = sfile, pa, epa, elons, jds, sect

end
