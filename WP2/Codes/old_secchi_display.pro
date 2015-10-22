pro secd_event, event

  common sci_raw_data, data, hdrs

  widget_control, event.id, get_uvalue = mnu
  widget_control, event.top, get_uvalue = state

  dflag = 0b
  case mnu of
     "QUIT": begin
        if event.value eq 'DONT' then (*state).flag = 0b $
        else (*state).flag = 1b
        widget_control, event.top, /destroy
     end

     "DIR": begin
        (*state).dir = event.value
        dflag = 1b
        ptr_free, (*state).files
     end

     "PDIR": begin
        dir = dialog_pickfile(dialog_parent = event.top, $
                              /direct, $
                              path = (*state).dir)

        if dir ne '' then begin
           (*state).dir = dir
           widget_control, (*state).dirid, set_value = dir
           dflag = 1b
        endif
        ptr_free, (*state).files
     end

     "PFILE": begin
        flist = dialog_pickfile(dialog_parent = event.top, $
                                path = (*state).dir, $
                                /multiple, $
                                /must, $
                                filter = "*.fts")
        if flist[0] ne '' then begin
           ptr_free, (*state).files
           (*state).files = ptr_new(flist)
           dflag = 1b
        endif
     end

     "REUSE": begin
        (*state).use_existing = event.select
        widget_control, (*state).selbase, sensitive = ~event.select
        dflag = 1b
     end

     "FULLMED": begin
        (*state).set_median = event.select
     end

     "STRIDE": (*state).stride = event.value
     "SHIFT": (*state).shift = event.value
     "MEDIAN": (*state).median = event.value
     "SIZE": (*state).isize = event.index
     "RATIO": begin
        (*state).ratio = event.select
        dflag = 1b
     end

     "MIN": (*state).range[0] = event.value
     "MAX": (*state).range[1] = event.value
     "KMIN": (*state).krange[0] = event.value
     "KMAX": (*state).krange[1] = event.value
     "DELAY": (*state).delay = event.value

     "COLOUR": xloadct, group = event.top

     "GRID": (*state).grid = event.index
  endcase

  if dflag then begin
     if (*state).use_existing then begin
        nf = n_elements(hdrs)
     endif else if ptr_valid((*state).files) then begin
        files = *(*state).files 
        nf =  n_elements(files)
     endif else files = file_search((*state).dir+'/*.fts', count = nf)
     if nf ne 0 then begin
        if (*state).use_existing then inst = hdrs[0].detector $
        else begin
           fh = headfits(files[0])
           inst = sxpar(fh, "DETECTOR")
        endelse
        case strtrim(inst) of
           "HI2": if (*state).is_beacon then begin
              if (*state).ratio then range = [.99, 1.01] $
              else range = [-1., 1.]
              shift = 0
              (*state).stride = 2
              (*state).median = 5
           endif else begin
              if (*state).ratio then range = [.99, 1.01] $
              else range = [-.2, .2]
              shift = (*state).stride
           end
           "HI1": begin
              if (*state).ratio then range = [.99, 1.01] $
              else if strtrim(sxpar(fh, 'BUNIT')) eq 'MSB' then $
                 range = [-3.e-13, 3.e-13] $
              else range = [-1., 1.]
              shift = (*state).stride
           end
           "COR1": begin
              if (*state).ratio then range = [.99, 1.01] $
              else range = [-2e-9, 2e-9]
              shift = 0
           end
           "COR2": begin
              if (*state).ratio then range = [.95, 1.05] $
              else range = [-5e-11, 5e-11]
              shift = 0
           end
           else: begin
              print, inst
              stop
           end
        endcase
        (*state).range = range
        (*state).shift = shift
        widget_control, (*state).minid, set_value = range[0]
        widget_control, (*state).maxid, set_value = range[1]
        if (*state).ratio then begin
           kr = 3*(range-1.)+1.
           widget_control, (*state).kminid, set_value = kr[0]
           widget_control, (*state).kmaxid, set_value = kr[1]
           (*state).krange = kr
        endif else begin
           widget_control, (*state).kminid, set_value = 3*range[0]
           widget_control, (*state).kmaxid, set_value = 3*range[1]
           (*state).krange = 3*range
        endelse
        widget_control, (*state).shid, set_value = shift
     endif
  endif


end

pro secchi_display, datadir = datadir, savedir = savedir, beacon = beacon

;+
; SECCHI_DISPLAY
;	Sets up the display/marking of secchi data.
;
; Usage:
;	secchi_display
;
; History:
;	Original: 15/12/08; SJT
;-

  common sci_raw_data, data, hdrs

  delay = 0.5
  stride = 1
  shift = 1
  median = 0
  ratio = 0b
  grid = 0
  use_existing = 0b
  set_median = 0b
  is_beacon = keyword_set(beacon)

  sizes = [0, 256, 512, 1024, 2048]
  isize = 0

  cd, current = here   
  if ~keyword_set(datadir) then datadir = here
  if ~keyword_set(savedir) then savedir = here

  files = file_search(datadir+'/*.fts', count = nf)
  if nf ne 0 then begin
     fh = headfits(files[0])
     inst = sxpar(fh, "DETECTOR")
     case strtrim(inst, 2) of
        "HI2": if (is_beacon) then begin
           range = [-1., 1.]
           shift = 0
           stride = 2
        endif else begin
           range = [-.2, .2]
           shift = 1
        endelse
        "HI1": begin
           range = [-1., 1.]
           shift = 1
        end
        "COR1": begin
           range = [-2e-9, 2e-9]
           shift = 0
        end
        "COR2": begin
           range = [-5e-11, 5e-11]
           shift = 0
        end
     endcase
  endif else range = fltarr(2)

  base = widget_base(title = "Secchi Display", $
                     /column)

  c1 = widget_label(base, $
                    value = "Secchi display setup")

  selbase = widget_base(base, $
                        /row)

  dirid = cw_ffield(selbase, $
                    label = "Data Directory", $
                    /text, $
                    xsize = 30, $
                    value = datadir, $
                    uvalue = "DIR")
  junk = widget_button(selbase, $
                       value = "Pick...", $
                       uvalue = "PDIR")
  junk = widget_button(selbase, $
                       value = "Files...", $
                       uvalue = "PFILE")

  if n_elements(data) ne 0 then begin
     jb = widget_base(base, $
                      /row)
     jbb = widget_base(jb, $
                       /nonexclusive)
     junk = widget_button(jbb, $
                          value = "Use existing raw data", $
                          uvalue = "REUSE")
  endif

  jb = widget_base(base, $
                   /row)
  jbb = widget_base(jb, $
                    /nonexclusive)
  junk = widget_button(jbb, $
                       value = "Use full set median as a base", $
                       uvalue = "FULLMED")

  diffbase = widget_base(base, $
                         /row)
  junk = cw_ffield(diffbase, $
                   label = "Difference stride", $
                   /int, $
                   value = stride, $
                   uvalue = "STRIDE")

  shid = cw_ffield(diffbase, $
                   label = "Star shift", $
                   /int, $
                   value = shift, $
                   uvalue = "SHIFT")

  jb = widget_base(base, $
                   /row)
  junk = cw_ffield(jb, $
                   label = "Smoothing median", $
                   /int, $
                   value = median, $
                   uvalue = "MEDIAN")

  jbb = widget_base(jb, $
                    /row)
  junk = widget_label(jbb, $
                      value = "Display size:")
  junk = widget_combobox(jbb, $
                         value = ['Original', string(sizes[1:*])], $
                         uvalue = "SIZE")
  widget_control, junk, set_combobox_select = isize

  jb = widget_base(base, $
                   /row)
  jbb = widget_base(jb, $
                    /row, $
                    /nonexclusive)
  junk = widget_button(jbb, $
                       value = "Use ratio", $
                       uvalue = "RATIO")
  
  jbb = widget_base(jb, $
                    /row)
  junk = widget_label(jbb, $
                      value = "Grid type")
  junk = widget_combobox(jbb, $
                         value = ["None", $
                                  "Lat & Lon", $
                                  "Elong & H-PA", $
                                  "Elong & E-PA"], $
                         uvalue = "GRID")

  jb = widget_base(base, $
                   /row)


  minid = cw_ffield(jb, $
                    label = "Data range: Min", $
                    /float, $
                    format = "(G11.3)", $
                    value = range[0], $
                    xsize = 12, $
                    uvalue = "MIN")
  maxid = cw_ffield(jb, $
                    label = "Max:", $
                    /float, $
                    format = "(G11.3)", $
                    value = range[1], $
                    xsize = 12, $
                    uvalue = "MAX")

  jb = widget_base(base, $
                   /row)


  kminid = cw_ffield(jb, $
                     label = "Kill range: Min", $
                     /float, $
                     format = "(G11.3)", $
                     value = 3*range[0], $
                     xsize = 12, $
                     uvalue = "KMIN")
  kmaxid = cw_ffield(jb, $
                     label = "Max:", $
                     /float, $
                     format = "(G11.3)", $
                     value = 3*range[1], $
                     xsize = 12, $
                     uvalue = "KMAX")

  jb = widget_base(base, $
                   /row)

  junk = cw_ffield(jb, $
                   label = "Frame delay", $
                   /float, $
                   value = delay, $
                   uvalue = "DELAY")

  junk = widget_button(jb, $
                       value = "Colour table...", $
                       uvalue = "COLOUR")



  junk = cw_bgroup(base, $
                   ['Display', 'Cancel'], $
                   /row, $
                   button_uvalue = ["DO", "DONT"], $
                   uvalue = "QUIT")

  state = ptr_new({secd_state, $
                   dir: datadir, $
                   files: ptr_new(), $
                   set_median: set_median, $
                   stride: stride, $
                   shift: shift, $
                   median: median, $
                   ratio: ratio, $
                   range: range, $
                   krange: 3*range, $
                   delay: delay, $
                   grid: grid, $
                   isize: isize, $
                   diffbase: diffbase, $
                   selbase: selbase, $
                   dirid: dirid, $
                   minid: minid, $
                   maxid: maxid, $
                   kminid: kminid, $
                   kmaxid: kmaxid, $
                   shid: shid, $
                   use_existing: use_existing, $
                   is_beacon: is_beacon, $
                   flag: 0b})

  widget_control, base, /real, set_uvalue = state
  xmanager, 'secd', base

  if (*state).flag eq 0 then begin
     ptr_free, state
     return
  endif

  if ~(*state).use_existing then begin
     if ptr_valid((*state).files) then $
        read_secchi_data, (*state).dir, hdrs, data, count = count, $
                          select = $
                          *(*state).files $
     else read_secchi_data, (*state).dir, hdrs, data, count = count
  endif

  dsettings = {secchi_set, $
               range: (*state).range, $
               krange: (*state).krange, $
               delay: (*state).delay, $
               grid: (*state).grid, $
               savedir: savedir}


  ddata = diff_secchi_data(data, stride = (*state).stride, median = $
                           (*state).median, ratio = (*state).ratio, $
                           size = sizes[(*state).isize], $
                           shift = (*state).shift, all_median = $
                           (*state).set_median)
  
  phdrs = hdrs[((*state).stride > 0):*]


  ptr_free, (*state).files, state

  secchi_show, ddata, phdrs, dsettings

end
