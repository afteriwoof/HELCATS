function mk_secchi_path, base, level, sc, instr, date

;+
; MK_SECCHI_PATH
;	Create a path for HI images
;
; Usage:
;	path = mk_secchi_path(base, level, sc, instr, date)
;
; Returns:
;	The path to find the images.
;
; Arguments:
;	base	string	The baseline path (SECCHI_ROOT).
;	level	int	The processing level (1 or 2)
;	sc	int	Which spacecraft (a=0, b=1)
;	instr	int	Which HI (1 or 2).
;	date	int(3)	The date (y,m,d).
;
; History:
;	Original: 8/9/14; SJT
;-

ps = path_sep()

path = base + ps + string(level, format="('L',i1)") + ps + $
       (['a','b'])[sc] + ps + 'img' + ps + $
       string(instr, format="('hi_',i1)") + ps + $
       string(date, format="(I4.4,2I2.2)")
return, path

end
