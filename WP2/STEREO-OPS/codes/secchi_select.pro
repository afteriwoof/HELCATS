pro secchi_s_event, event

  widget_control, event.id, get_uvalue = mnu
  widget_control, event.top, get_uvalue = state

  case mnu of
     'DO': begin
        (*state).iexit = 1
        (*state).selected = ptr_new(widget_info((*state).flistid, $
                                                /list_select))
        widget_control, event.top, /destroy
     end
     'DONT': begin
        (*state).iexit = 0
        widget_control, event.top, /destroy
     end

     'BASE': (*state).base = event.value
     'SC': (*state).sc = event.index
     'HI': begin
        (*state).hi = event.index+1
        if event.index eq 0 then begin ; HI 1
           widget_control, (*state).bglid, set_value=['1','11']
        endif else begin        ; HI 2
           widget_control, (*state).bglid, set_value=['3','11']
        endelse
     end
     'LEVEL': begin
        (*state).level = event.index+1
        widget_control, (*state).lbase, map = event.index eq 1
        widget_control, (*state).rbase, map = event.index eq 0
     end

     'UNIT': (*state).unit = event.index

     'SYEAR': (*state).start[0] = event.value
     'SMON': (*state).start[1] = event.value
     'SDAY': (*state).start[2] = event.value
     'SUP': begin
        jd = julday((*state).start[1], (*state).start[2], (*state).start[0])
        jd = jd+1
        caldat, jd, mn, dy, yr
        (*state).start[0] = yr
        (*state).start[1] = mn
        (*state).start[2] = dy
        widget_control, (*state).syid, set_value=yr
        widget_control, (*state).smid, set_value=mn
        widget_control, (*state).sdid, set_value=dy
     end
     'SDOWN': begin
        jd = julday((*state).start[1], (*state).start[2], (*state).start[0])
        jd = jd-1
        caldat, jd, mn, dy, yr
        (*state).start[0] = yr
        (*state).start[1] = mn
        (*state).start[2] = dy
        widget_control, (*state).syid, set_value=yr
        widget_control, (*state).smid, set_value=mn
        widget_control, (*state).sdid, set_value=dy
     end
     'ECOPY': begin
        widget_control, (*state).eyid, get_value=yr
        widget_control, (*state).emid, get_value=mn
        widget_control, (*state).edid, get_value=dy
        (*state).start[0] = yr
        (*state).start[1] = mn
        (*state).start[2] = dy
        widget_control, (*state).syid, set_value=yr
        widget_control, (*state).smid, set_value=mn
        widget_control, (*state).sdid, set_value=dy
     end

     'EYEAR': (*state).stop[0] = event.value
     'EMON': (*state).stop[1] = event.value
     'EDAY': (*state).stop[2] = event.value
     'EUP': begin
        jd = julday((*state).stop[1], (*state).stop[2], (*state).stop[0])
        jd = jd+1
        caldat, jd, mn, dy, yr
        (*state).stop[0] = yr
        (*state).stop[1] = mn
        (*state).stop[2] = dy
        widget_control, (*state).eyid, set_value=yr
        widget_control, (*state).emid, set_value=mn
        widget_control, (*state).edid, set_value=dy
     end
     'EDOWN': begin
        jd = julday((*state).stop[1], (*state).stop[2], (*state).stop[0])
        jd = jd-1
        caldat, jd, mn, dy, yr
        (*state).stop[0] = yr
        (*state).stop[1] = mn
        (*state).stop[2] = dy
        widget_control, (*state).eyid, set_value=yr
        widget_control, (*state).emid, set_value=mn
        widget_control, (*state).edid, set_value=dy
     end
     'SCOPY': begin
        widget_control, (*state).syid, get_value=yr
        widget_control, (*state).smid, get_value=mn
        widget_control, (*state).sdid, get_value=dy
        (*state).stop[0] = yr
        (*state).stop[1] = mn
        (*state).stop[2] = dy
        widget_control, (*state).eyid, set_value=yr
        widget_control, (*state).emid, set_value=mn
        widget_control, (*state).edid, set_value=dy
     end

     'BGL': (*state).bg_length = event.index
     '1024': (*state).r1024 = event.index

     'UPDATE': begin
        jd0 = julday((*state).start[1], (*state).start[2], (*state).start[0])
        jd1 = julday((*state).stop[1], (*state).stop[2], (*state).stop[0])
        
        sflag = 1b

        if (*state).level eq 2 then begin
           if (*state).bg_length eq 0 then begin
              if (*state).hi eq 1 then bglen = 1 $
              else bglen = 3
           endif else bglen = 11
        endif

        for jd = jd0, jd1 do begin
           caldat, jd, mn, dy, yr
           path = mk_secchi_path((*state).basedir, $
                                 (*state).level, $
                                 (*state).sc, $
                                 (*state).hi, $
                                 [yr, mn, dy])

           dlist = file_search(path+path_sep()+'*.fts')
           blist = file_basename(dlist)
                                ; Note other parameters should be
                                ; fixed by the directory

           if (*state).level eq 2 then begin
              locs = where(match_secchi_name(blist, unit=(*state).unit, $
                                             background = bglen), nm)
           endif else begin
              locs = where(match_secchi_name(blist, unit=(*state).unit), $
                           nm)
              if nm gt 0 then  case (*state).r1024 of
                 0: begin
                    for j = 0l, nm-1 do begin
                       hdr = headfits(dlist[locs[j]])
                       naxis1 = sxpar(hdr, 'NAXIS1')
                       naxis2 = sxpar(hdr, 'NAXIS2')
                       if naxis1 ne 1024 or naxis2 ne 1024 then locs[j] = -1
                    endfor
                 end
                 1: begin
                    for j = 0l, nm-1 do begin
                       hdr = headfits(dlist[locs[j]])
                       naxis1 = sxpar(hdr, 'NAXIS1')
                       naxis2 = sxpar(hdr, 'NAXIS2')
                       if naxis1 ne 2048 or naxis2 ne 2048 then locs[j] = -1
                    endfor
                 end
                 2:
              endcase
              ll = where(locs ge 0, nm)
              if (nm gt 0) then locs = locs[ll]
           endelse

           if nm eq 0 then continue
           if sflag then begin
              dlist_all = dlist[locs]
              blist_all = blist[locs]
              sflag = 0b
           endif else begin
              dlist_all = [dlist_all, dlist[locs]]
              blist_all = [blist_all, blist[locs]]
           endelse
        endfor

        if ptr_valid((*state).flist) then ptr_free, (*state).flist
        (*state).flist = ptr_new(dlist_all)
        widget_control, (*state).flistid, set_value=blist_all
     end

     'PICK': begin
        slist = widget_info(event.id, /list_select)
        widget_control, (*state).dobut, sensitive = slist[0] ne -1
     end
     'ALL': begin
        n = n_elements(*(*state).flist)
        if n eq 0 then begin
           widget_control, (*state).dobut, sensitive = 0
        endif else begin
           isel = lindgen(n)
           widget_control, (*state).flistid, set_list_select=isel
           widget_control, (*state).dobut, sensitive = 1
        endelse
     end
  endcase

end

function secchi_select, stereo=stereo, hi=hi, level=level, unit=unit, $
                        root_dir=root_dir, count=count, group=group

;+
; SECCHI_SELECT
; 	Select files according to various parameters.
;
; Usage:
; 	files = secchi_select()
;
; Return:
; 	The list of files. An empty string is returned if no files are
; 	selected.
;
; Keywords:
;	stereo	string	Which spacecraft (a or b)
;	hi	int	Which HI (1 or 2)
;	level	int	Processing level (1 or 2)
;	unit	int	Image unit (0=DN, 1=MSB, 2=S10)
;	root_dir string	The root directory (default $SECCHI_ROOT).
;	count	long	A named variable to return the number of files
;			selected.
;	group	long	The ID of the generating widget.
;
; History:
;	Original: 9/9/14; SJT
;-

; Create up & down arrow bitmaps
  down =  bytarr(11, 6)
  down[5, 0] = 255b
  down[4:6, 1] = 255b
  down[3:7, 2] = 255b
  down[2:8, 3] = 255b
  down[1:9, 4] = 255b
  down[*, 5] = 255b
  up = reverse(down, 2)
  bdown = cvttobm(down)
  bup = cvttobm(up)
  xextra = 5

  if keyword_set(stereo) then dsc = stereo $
  else dsc = 0
  if keyword_set(hi) then dhi = hi $
  else dhi = 2

  if keyword_set(level) then dlevel = level $
  else dlevel = 2
  if keyword_set(unit) then dunit = unit $
  else dunit = 0
  
  if keyword_set(root_dir) then $
     basedir = root_dir $
  else basedir = getenv("SECCHI_ROOT")
  if basedir eq "" then basedir = "."
  
  base = widget_base(/column, $
                     title="HI Image selector", $
                     group=group, $
                     modal=keyword_set(group))

  label = widget_label(base, $
                      value="HI Image selector")

  pathid = cw_ffield(base, $
                     /text, $
                     xsize=40, $
                     label="Base directory", $
                     value=basedir, $
                     uvalue="BASE")

; Pick spacecraft and instrument

  jb = widget_base(base, $
                   /row)

  scid = widget_droplist(jb, $
                         value=["A","B"], $
                         title="Spacecraft", $
                         uvalue="SC")
  widget_control, scid, set_droplist_select = dsc

  hid = widget_droplist(jb, $
                        value=["HI-1", "HI-2"], $
                        title="Instrument", $
                        uvalue="HI")
  widget_control, hid, set_droplist_select = dhi-1

  
; processing level and unit

  jb = widget_base(base, $
                   /row)

  lvlid = widget_droplist(jb, $
                          value=['1', '2'], $
                          title="Level", $
                          uvalue="LEVEL")
  widget_control, lvlid, set_droplist_select = dlevel-1

  unitid = widget_droplist(jb, $
                           value=["DN", "MSB", "S10"], $
                           title="Unit", $
                           uvalue="UNIT")
  widget_control, unitid, set_droplist_select = dunit

; Date range

; Start

  jb = widget_base(base, $
                   /row)


  jb1 = widget_base(jb, $
                    /column)
  jb2 = widget_base(jb1, $
                    /row)

  syid = cw_ffield(jb2, $
                   label="Start date (Y, M, D)", $
                   /int, $
                   xsize=5, $
                   uvalue='SYEAR')

  smid = cw_ffield(jb2, $
                   label=',', $
                   /int, $
                   xsize=3, $
                   uvalue='SMON')

  sdid = cw_ffield(jb2, $
                   label=',', $
                   /int, $
                   xsize=3, $
                   uvalue='SDAY')

  jbb = widget_base(jb2, $
                    /column, $
                    xpad = 0, $
                    ypad = 0, $
                    space = 0)
  junk = widget_button(jbb, $
                       value = bup, $
                       uvalue = 'SUP', $
                       x_bitmap_extra = xextra)
  junk = widget_button(jbb, $
                       value = bdown, $
                       uvalue = 'SDOWN', $
                       x_bitmap_extra = xextra)
  junk = widget_button(jb1, $
                       value='Copy end date', $
                       uvalue='ECOPY')

; End

  jb = widget_base(base, $
                   /row)
  jb1 = widget_base(jb, $
                    /column)
  jb2 = widget_base(jb1, $
                    /row)

  eyid = cw_ffield(jb2, $
                   label="End date (Y, M, D)", $
                   /int, $
                   xsize=5, $
                   uvalue='EYEAR')

  emid = cw_ffield(jb2, $
                   label=',', $
                   /int, $
                   xsize=3, $
                   uvalue='EMON')

  edid = cw_ffield(jb2, $
                   label=',', $
                   /int, $
                   xsize=3, $
                   uvalue='EDAY')

  jbb = widget_base(jb2, $
                    /column, $
                    xpad = 0, $
                    ypad = 0, $
                    space = 0)
  junk = widget_button(jbb, $
                       value = bup, $
                       uvalue = 'EUP', $
                       x_bitmap_extra = xextra)
  junk = widget_button(jbb, $
                       value = bdown, $
                       uvalue = 'EDOWN', $
                       x_bitmap_extra = xextra)
  junk = widget_button(jb1, $
                       value='Copy start date', $
                       uvalue='SCOPY')

  abase = widget_base(base)
  lbase = widget_base(abase, $
                      /row, $
                      map=dlevel eq 2)

  if dhi eq 1 then bgs = ['1','11'] $
  else bgs = ['3','11']

  bglid = widget_droplist(lbase, $
                          value=bgs, $
                          title="Background length", $
                          uvalue='BGL')

  rbase = widget_base(abase, $
                      /row, $
                      map=dlevel eq 1)

  junk = widget_droplist(rbase, $
                         title = "Restrict images?", $
                         value = ['1024', '2048', 'All'], $
                         uvalue='1024')
  widget_control, junk, set_button=1

  junk = widget_button(base, $
                       value='Update list', $
                       uvalue='UPDATE')

  flistid = widget_list(base, $
                        ysize=15, $
                        /multiple, $
                        uvalue="PICK")
  junk = widget_button(base, $
                       value='Select all', $
                       uvalue='ALL')

  jb = widget_base(base, $
                   /row)

  dobut = widget_button(jb, $
                        value="Apply", $
                        uvalue="DO", $
                        sensitive=0)

  junk = widget_button(jb, $
                       value='Cancel', $
                       uvalue='DONT')

  state = ptr_new({secchi_s_state, $
                   basedir: basedir, $
                   sc: dsc, $
                   hi: dhi, $
                   level: dlevel, $
                   unit: dunit, $
                   start: intarr(3), $
                   stop: intarr(3), $
                   bg_length: 0, $
                   r1024: 0, $
                   flist: ptr_new(), $
                   selected: ptr_new(), $
                   syid: syid, $
                   smid: smid, $
                   sdid: sdid, $
                   eyid: eyid, $
                   emid: emid, $
                   edid: edid, $
                   lbase: lbase, $
                   rbase: rbase, $
                   bglid: bglid, $
                   flistid: flistid, $
                   dobut: dobut, $
                   iexit: 0})

  widget_control, base, /real, set_uvalue=state

  xmanager, 'secchi_s', base

  if (*state).iexit eq 1 then begin
     files = (*(*state).flist)[*(*state).selected] 
     count = n_elements(files)
  endif else begin
     files = ''
     count = 0
  endelse

  ptr_free, (*state).flist, (*state).selected
  ptr_free, state

  return, files
end
