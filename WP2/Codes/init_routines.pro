; Define plotting region for panel xmap,ymap out of xmaps,ymaps
; Setting /SQUARE constrains the panels to be square
; Setting /BAR leaves enough room on the right hand side for a colour bar
; Setting /NO_CENTRE means panels aren't centred on the page

	PRO define_panel,xmaps,ymaps,xmap,ymap,square=square,no_gap=no_gap,bar=bar, $
		no_centre=no_centre,richard=richard,small=small


; Default is one panel on screen
	IF N_PARAMS() NE 4 THEN BEGIN & xmaps=1 & ymaps=1 & xmap=0 & ymap=0 & ENDIF

; Check for bad x and y
	IF xmap GE xmaps OR ymap GE ymaps THEN BEGIN
		PRINT,'WARNING: panel positions out of range'
		xmap=0
		ymap=0
	ENDIF	

; Initialize plotting preferences
; x,ysize	-proportion of screen to put panels in
; x,yorigin	-where to start page from
; l,r,t,bmargin -left, right, top and bottom margins around plot window as fractions of the panel
; If no_gap is in force then tmargin=bmargin=0 and move things about

	IF     KEYWORD_SET(bar)      THEN xsize=0.83
	IF NOT KEYWORD_SET(bar)      THEN xsize=0.95
	ysize=0.83
	xorigin=0.05
	yorigin=0.02
	lmargin=0.15
	rmargin=0.05
	tmargin=0.05
	bmargin=0.15		
	IF KEYWORD_SET(no_gap) THEN BEGIN
		tmargin=0
		bmargin=0
		ysize=0.73
		yorigin=0.1		
	ENDIF

; Calculate size of each panel
	xframe=xsize/xmaps
	yframe=ysize/ymaps

; If /SQUARE option is set then constrain plotting window to be square -
; recalculate xframe and yframe accordingly, taking into account the
; device aspect ratio
	IF KEYWORD_SET(square) THEN BEGIN
		lmargin=0.035
		rmargin=0.035
		tmargin=0.035
		bmargin=0.035
		
		lmargin=0.08
		rmargin=0.08
		tmargin=0.08
		bmargin=0.08
		
		lmargin=0.12
		rmargin=0.12
		tmargin=0.12	
		bmargin=0.12
				
		if keyword_set(small) then begin
			lmargin=0.225
			rmargin=0.225
			tmargin=0.225
			bmargin=0.225
		endif
		
		if keyword_set(richard) then begin
			lmargin=0.05
			rmargin=0.05
			tmargin=0.05
			bmargin=0.05		
		endif
				
		if keyword_set(richard) then begin
			lmargin=0.05
			rmargin=0.05
			tmargin=0.05
			bmargin=0.05		
		endif		
					
		aspect_ratio=1.0*!D.Y_SIZE/!D.X_SIZE
		xpanel=xframe*(1-lmargin-rmargin)
		ypanel=yframe*(1-tmargin-bmargin)
		IF xmaps*ypanel*aspect_ratio/(1-lmargin-rmargin) GT xsize THEN $
			ypanel=xpanel/aspect_ratio ELSE xpanel=ypanel*aspect_ratio	
		xframe=xpanel/(1-lmargin-rmargin)
		yframe=ypanel/(1-tmargin-bmargin)
	ENDIF

	x1=(xmap+lmargin)*xframe
	y1=(ymaps-ymap-1+bmargin)*yframe
	x2=(xmap+1-rmargin)*xframe
	y2=(ymaps-ymap-tmargin)*yframe

; Centre plotting area
	IF KEYWORD_SET(NO_CENTRE) THEN BEGIN
		xcentre=0
		ycentre=0
	ENDIF ELSE BEGIN
		xcentre=(xsize-xframe*xmaps)*0.5
		ycentre=(ysize-yframe*ymaps)*0.5
	ENDELSE

	!P.POSITION=[x1+xcentre+xorigin,y1+ycentre+yorigin,x2+xcentre+xorigin,y2+ycentre+yorigin]
	
	END

;--------------------------------------------------------------------

; Open postscript file, portrait and black and white by default

	PRO open_ps,file,landscape=landscape,colour=colour,small=small
	
	IF N_PARAMS() EQ 0 THEN file='piccy.ps'	
	SET_PLOT,'PS'
	
	!p.font=0
	
	IF     KEYWORD_SET(colour)    then DEVICE,FILENAME=file,/HELVETICA,color=1,bits=8
		  
	IF NOT KEYWORD_SET(colour)    then DEVICE,FILENAME=file,/HELVETICA,color=0,bits=8
	
	IF     KEYWORD_SET(landscape) then DEVICE,/LANDSCAPE,XOFFSET=1.0,YOFFSET=28.7,XSIZE=27.7,YSIZE=19.0,FONT_SIZE=18,SCALE_FACTOR=1
	
	IF NOT KEYWORD_SET(landscape) then DEVICE,/PORTRAIT,XOFFSET=1.0,YOFFSET=1.0,XSIZE=19.0,YSIZE=27.7,FONT_SIZE=18,SCALE_FACTOR=1
	
	IF KEYWORD_SET(small) then DEVICE,/PORTRAIT,XOFFSET=1.0,YOFFSET=1.0,XSIZE=15.0,YSIZE=15.0,FONT_SIZE=18,SCALE_FACTOR=1
		       
	END
	
;--------------------------------------------------------------------
	
; Close postscript file

	PRO close_ps
	
	SET_PLOT,'ps'
	DEVICE,/CLOSE
	
	!p.font=-1	
	
	SET_PLOT,'X'
	
		
	END

;-----------------------------------------------------------------------

	PRO plot_colourbar,zrange,legend=legend,no_ticks=no_ticks,chsize=chsize
		
	minval=zrange(0)
	maxval=zrange(1)
		
		
; Colours		
	no_colours=!d.n_colors-1
	lvl=minval+FINDGEN(no_colours)*(maxval-minval)/no_colours

; Initialize colour bar position
	IF NOT KEYWORD_SET(no_ticks) THEN no_ticks=10
	
	xpos=!p.position(2)+0.02
	xbox=0.03
	fract=(!p.position(3)-!p.position(1))/15.0
	ypos=!p.position(1)+1.0*fract
	ybox_cols= (!p.position(3)-!p.position(1)-2.0*fract)/no_colours
	ybox_ticks=(!p.position(3)-!p.position(1)-2.0*fract)/no_ticks
	char=0.5
	IF KEYWORD_SET(chsize) then char=chsize

; Draw coloured boxes
	FOR level=0,no_colours-1 DO					$
		POLYFILL,[xpos,xpos+xbox,xpos+xbox,xpos],		$
			 [ypos+ybox_cols*level,ypos+ybox_cols*level,		$
			  ypos+ybox_cols*(level+1),ypos+ybox_cols*(level+1)],	$
			  COLOR=level,/NORMAL
; Draw outline
	FOR level=0,no_ticks-1 DO 					$
		PLOTS,xpos+xbox*[0,1,1,0,0],ypos+ybox_ticks*(level+[0,0,1,1,0]),/NORMAL

; Plot levels
		IF FIX((maxval-minval)/no_ticks) NE FLOAT((maxval-minval))/no_ticks THEN BEGIN
			level_format='(F10.1)'
		ENDIF ELSE BEGIN
			level_format='(I)'
		ENDELSE
	
	lvl=minval+FINDGEN(no_ticks)*(maxval-minval)/no_ticks
	FOR level=1,no_ticks-1 DO BEGIN
		numb=STRTRIM(STRING(lvl(level),FORMAT=level_format),2)
		XYOUTS,xpos+1.25*xbox,ypos+ybox_ticks*level-0.1*ybox_ticks,		$
			numb,CHARSIZE=char,/NORMAL
	ENDFOR

; Plot legend
	IF KEYWORD_SET(legend) THEN begin
		title=legend
		XYOUTS,xpos+4.0*xbox,ypos+no_colours*ybox_cols*0.5,title,	$
			ORIENTATION=270,ALIGNMENT=0.5,CHARSIZE=char,/NORMAL
	ENDIF
		

	END
	
	

