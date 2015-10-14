function match_secchi_name, name, date=date, time=time, level=level, $
                            unit=unit, instr=instr, sc=sc, $
                            background=background

;+
; MATCH_SECCHI_NAME
; 	Check if a secchi filename matches the specified parameters.
; 
; Usage:
; 	match = match_secchi_name(name, <keywords>)
;
; Argument:
;	name	string	The name(s) to match.
;
; Keywords:
;	date	int(3)	The date in y,m,d form
;	time	int(3)	The time in h,m,s form
;	level	int	The processing level
;	unit	int	The data unit (0 = D/N, 1 = MSB, 2 = S10)
;	sc	string	Which spacecraft
;	instr	int	Which HI
;	background int	The length of the background subtraction
;			(Level 2 only)
;
; Notes:
;	Specifying background for level 1 data will always yield
;	false.
; 20071231_160901_2th1B_br11.fts
; 012345678901234567890123456789
; 0         1         2
;
; History:
;	Original: 8/9/14; SJT
;-

  if size(name, /n_dim) eq 0 then imatch = 1b $
  else imatch = make_array(size=size(name), /byte, value=1b)

  if n_elements(date) ne 0 then begin
     dstr = string(date, format="(I4.4,2i2.2)")
     imatch and= strmid(name, 0, 8) eq dstr
  endif

  if n_elements(time) ne 0 then begin
     tstr = string(time, format="(3I2.2)")
     imatch and= strmid(name, 9, 6) eq tstr
  endif

  if n_elements(level) ne 0 then begin
     lstr = string(level, format="(i1)")
     imatch and= strmid(name, 16, 1) eq lstr
  endif

  if n_elements(unit) ne 0 then begin
     ulist = ['4', 'b', 't']
     ustr = ulist[unit]
     imatch and= strmid(name, 17, 1) eq ustr
  endif

  if n_elements(instr) ne 0 then begin
     istr = string(instr, format="('h',i1)")
     imatch and= strmid(name, 18, 2) eq istr
  endif

  if n_elements(sc) ne 0 then begin
     sstr = strupcase(sc)
     imatch and= strmid(name, 20, 1) eq sstr
  endif

  if n_elements(background) ne 0 then begin
     bstr = string(background, format="('br',i2.2)")
     imatch and= strmid(name, 22, 4) eq bstr
  end

  return, imatch

end
