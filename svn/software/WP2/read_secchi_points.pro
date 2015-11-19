pro read_secchi_points, file, jd, x, y, hlon, hlat, elong, hpa, epa, $
                        val

nlines = file_lines(file)-1

jd = dblarr(nlines)
x = intarr(nlines)
y = intarr(nlines)
hlon = fltarr(nlines)
hlat = fltarr(nlines)
elong = fltarr(nlines)
hpa = fltarr(nlines)
epa = fltarr(nlines)
val = fltarr(nlines)

openr, ilu, /get, file

inln = ''
readf, ilu, inln                ; Skip header

jdi = 0.d0
xi = 0
yi = 0
hloni = 0.
hlati = 0.
elongi = 0.
hpai = 0.
epai = 0.
vali = 0.

for j = 0, nlines-1 do begin
    readf, ilu, jdi, xi, yi, hloni, hlati, elongi, hpai, epai, $
                        vali
    jd[j] = jdi
    x[j] = xi
    y[j] = yi
    hlon[j] = hloni
    hlat[j] = hlati
    elong[j] = elongi
    hpa[j] = hpai
    epa[j] = epai
    val[j] = vali
endfor

free_lun, ilu

end
