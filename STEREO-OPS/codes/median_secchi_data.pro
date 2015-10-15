function median_secchi_data, data, median = median, size $
                             = size, ratio = ratio

;+
; MEDIAN_SECCHI_DATA
;	Make a difference of a block of secchi data from the median of
;	the block.
;
; Usage:
;	ddata=median_secchi_data(data)
;
; Returns:
;	ddata	float	The running difference data block
;
; Argument:
;	data	float	The original images.
;
; Keywords:
;	median	int	Optional median filter to apply (Default:
;			none)
;	size	int	Resize the image to this size (must be a power
;			of 2).
;	shift	int	Use this shift from image to image for star
;			subtraction (Default=stride)
;	/ratio		If set, then use a ratio rather than a
;			difference.
;
; History:
;	Original (after diff_secchi_data): 26/1/09 ; SJT
;-

if n_elements(median) eq 0 then median = 0
sz = size(data, /dim)

nimo = sz[2]

if keyword_set(size) then ddata = fltarr(size, size, nimo) $
else ddata = fltarr(sz[0], sz[1], nimo)

base = median(data, dim = 3)

for j = 0, nimo-1 do begin
    tmp = data[*, *, j]
    if median lt 0 then tmp =  median(tmp, -median)
    tmp -= base

    if median gt 0 then tmp = median(tmp, median)

    if keyword_set(size) then tmp = rebin(tmp, size, size)

    ddata[*, *, j] = tmp
endfor

return, ddata

end
