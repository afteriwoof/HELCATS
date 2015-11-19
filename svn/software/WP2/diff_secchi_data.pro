function diff_secchi_data, data, stride = stride, median = median, size $
                           = size, ratio = ratio, shift = shift, $
                           all_median = all_median, align=align, headers=headers

;+
; DIFF_SECCHI_DATA
;	Make a running difference from a block of secchi data.
;
; Usage:
;	ddata=diff_secchi_data(data)
;
; Returns:
;	ddata	float	The running difference data block
;
; Argument:
;	data	float	The original images.
;
; Keywords:
;	stride	int	How many images to step in the running diff
;			(Default=1)
;	median	int	Optional median filter to apply (Default:
;			none)
;	size	int	Resize the image to this size (must be a power
;			of 2).
;	shift	int	Use this shift from image to image for star
;			subtraction (Default=stride)
;	/ratio		If set, then use a ratio rather than a
;			difference.
;	/all_median	If set, subtract a full dataset median (crude
;			F-corona subtraction)
;	/align		If set, then use hi_align_image rather than a
;			shift distance (overrides the SHIFT parameter).
;	headers	struct	The FITS headers for the image block (must be
;			given if ALIGN is specfied).
;
; History:
;	Original (after parts of secchi_geometry): 15/12/08; SJT
;	Add negative stride to be like "orbit6e": 18/12/08; SJT
;	Add align keyword: 9/9/14; SJT
;-

if n_elements(stride) eq 0 then stride = 1
if keyword_set(align) then begin
   if not keyword_set(headers) then $
      message, /error, $
               'DIFF_SECCHI_DATA: The ALIGN keyword requires FITS headers to be present'
   shift = 0
endif else if n_elements(shift) eq 0 then shift = stride

sz = size(data, /dim)

if stride gt 0 then nimo = sz[2]-stride $
else nimo = sz[2]

if keyword_set(size) then ddata = fltarr(size, size, nimo) $
else ddata = fltarr(sz[0], sz[1], nimo)

if keyword_set(all_median) then base = median(data, dim = 3) $
else base = 0.

for j = 0, nimo-1 do begin
    t0 = data[*, *, j+(stride > 0)]-base
    
    if stride gt 0 then begin
       if keyword_set(align) then $
          t1 = hi_align_image(headers[j], data[*, *, j]-base, $
                              headers[j+(stride > 0)], /radec) $
       else t1 = shift(data[*, *, j]-base, shift, 0) 

       if keyword_set(ratio) then tmp = t0/t1 $
       else tmp = t0-t1
    endif else if stride lt 0 then begin
        st = -stride
        t1 = fltarr(sz[0:1])
        n = 0.
        for k = stride, st do begin
            if k eq 0 then continue
            if j+k lt 0 or j+k ge sz[2] then continue
            if keyword_set(align) then $
               t1 += hi_align_image(headers[j+k], data[*, *, j+k]-base, $
                                    headers[j+(stride > 0)], /radec) $ 
            else t1 += shift(data[*, *, j+k]-base, shift*k, 0)
            n++
        endfor
        t1 /= n

        if keyword_set(ratio) then tmp = t0/t1 $
        else tmp = t0-t1
    endif else tmp = t0

    if keyword_set(median) then tmp = median(tmp, median)

    if keyword_set(size) then tmp = rebin(tmp, size, size)

    ddata[*, *, j] = tmp
endfor

return, ddata

end
