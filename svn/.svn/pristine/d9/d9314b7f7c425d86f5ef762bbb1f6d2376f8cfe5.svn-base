pro read_secchi_data, dir, hdrs, data, select = select, instr = $
                      instr, count = count, filter=filter, flist=flist

;+
; READ_SECCHI_DATA
;	Read the secchi images from a directory
;
; Usage:
;	read_secchi_data, dir, hdrs, data
;
; Arguments:
;	dir	string	The directory from which to read.
;	hdrs	struct	The fits headers from the files.
;	data	float	The images.
;
;
; Keywords:
;	instr	string	If specfied then only get the images for the
;			specified instrument.
;	select	int/str	If this is a string array, then only read the
;			files listed (dir is ignored in this case)
;			If it is a integer array of 1 or 2 elements
;			then only select the given range. If it is an
;			integer array of more elements then it is a
;			list of indices.
;	count	long	A named variable to contain the number of images.
;	filter	string	A filename filter (ignored if select is a
;			string array).
;	flist	string	A named variable to return the names of the
;			files opened.
;
; History:
;	Original (extracted): 15/12/08
;	Add filter & flist keyword: 24/9/14; SJT
;-

  if ~keyword_set(filter) then filter = '*.fts*'

  if n_elements(select) ne 0 then begin
     if size(select, /tname) eq 'STRING' then flist = select $
     else begin
        flist = file_search(dir+'/'+filter, count=nfound)
        if select[0] ge nfound then begin
           count=0
           flist = ''
           return
        endif
        case n_elements(select) of
           1: flist = flist[select] 
           2: flist = flist[select[0]:select[1]<(nfound-1)]
           else: begin
              locs = where(select lt nfound, nv)
              if nv eq 0 then begin
                 flist = ''
                 count = 0
                 return
              endif
              flist = flist[select[locs]]
           end
        endcase
     endelse
  endif else begin 
     flist = file_search(dir+'/'+filter) ; lists all the available fits files
                                ; in the
                                ; directory dir in the
                                ; variable "flist"
  endelse

  if flist[0] eq '' then begin
     count=0
     return
  endif

  if keyword_set(instr) then begin
     switch strupcase(instr) of
        'H1A':
        'HI-1A': begin
           det = 'HI1'
           obs = 'STEREO_A'
           break
        end

        'H1B':
        'HI-1B': begin
           det = 'HI1'
           obs = 'STEREO_B'
           break
        end

        'H2A':
        'HI-2A': begin
           det = 'HI2'
           obs = 'STEREO_A'
           break
        end

        'H2B':
        'HI-2B': begin
           det = 'HI2'
           obs = 'STEREO_B'
           break
        end

        'C1A':
        'COR1-A': begin
           det = 'COR1'
           obs = 'STEREO_A'
           break
        end

        'C1B':
        'COR1-B': begin
           det = 'COR1'
           obs = 'STEREO_B'
           break
        end

        'C2A':
        'COR2-A': begin
           det = 'COR2'
           obs = 'STEREO_A'
           break
        end

        'C2B':
        'COR2-B': begin
           det = 'COR2'
           obs = 'STEREO_B'
           break
        end

     endswitch

     iuse = bytarr(n_elements(flist))
     for j = 0,  n_elements(flist)-1 do begin
        fh = headfits(flist[j])
        iuse[j] = (sxpar(fh, 'DETECTOR') eq det) && $
           (sxpar(fh, 'OBSRVTRY') eq obs)
     endfor
     locs = where(iuse)
     flist = flist[locs]
  endif

  count = n_elements(flist)
  mreadfits, flist, hdrs, data  ;, /nohistory, /nocomments

  if strtrim(hdrs[0].detector) eq 'COR1' then data -= 32768. ; COR1 has
                                ; a spurious BZERO field.
  data = float(data)            ; Don't try to return 64-bit images as 64-bits 

end

