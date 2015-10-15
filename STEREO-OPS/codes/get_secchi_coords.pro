pro get_secchi_coords, state, x, y, coord, elong, pa, epa 

coord = wcs_get_coord((*state.wcs)[state.current], [x, y]) 
if (*state.iscor)[state.current] then coord /= 3600. ; COR coords
                                ; are in arcsec, HI in degrees.

coor = coord*!dtor
elong = acos(cos(coor[0])*cos(coor[1]))
pa = 90.-asin(sin(coor[1])/sin(elong))*!radeg
if coord[0] gt 0 then pa = 360.-pa
elong *= !radeg

epa = pa + (*state.tilt)[state.current]
if epa lt 0 then epa += 360.
if epa gt 360. then epa -= 360.

end
