function eh_tilt, jd, dlon = dlon

an1900 = 74.3666667
jd1900 = doy2jd([1900, 0])
dany = 0.014

tilt0 = 7.25
tt0 = tan(tilt0*!dtor)

an = an1900+dany*(jd-jd1900)/365.2242

if ~keyword_set(dlon) then dlon = 0.0
sunpos, jd, ra, dec, elon

slon = elon+dlon

return, atan(-tt0*cos((slon-an)*!dtor))*!radeg

end
