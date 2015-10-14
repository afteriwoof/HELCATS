pro do_prep, dir, pattern = pattern, polar = polar
;+
; DO_PREP
;	Basic secchi_prep wrapper
;-

if n_params() eq 0 then dir =  '.'
if ~keyword_set(pattern) then pattern =  '*.fts*'

a = file_search(dir+'/raw', pattern, count = nrf)
if nrf eq 0 then stop

secchi_prep, a, headers, images, savepath = dir+'/prepped/', $
  /write_fts, /silent, polariz_on = polar, pb = polar

end
