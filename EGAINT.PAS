(*
 * Copyright 1989, 1990 Eric Ng
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 1, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * without any warranty whatsoever, without even the implied warranties
 * of merchantability or fitness for a particular purpose.  See the
 * accompanying GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to:
 *
 * Free Software Foundation, Inc.
 * 675 Massachusetts Avenue
 * Cambridge, Massachusetts 02139
 *)

{$a-}
{$b-}
{$d-}
{$e-}
{$f-}
{$i-}
{$l-}
{$n-}
{$o-}
{$r-}
{$s-}
{$v-}

Program egaint;

 Uses
  Crt, Dos, Driver, Fonts, Graph;


 Const
  id		  : String [6]	= 'egaint';
  version	  : String [7]	= '0.94.13';
  copyright	  : String [27] = 'Copyright 1989-90 Eric Ng';

  nshapes	  = 26; 	    { different shapes }
  shapesiz	  = 5;		    { max size of each shape }
  xshapelevels	  = 4;		    { levels (classic, easy, medium, hard) }
  xshapeclassic   = 7;		    { different classic shapes }
  xshapeeasy	  = 13; 	    { different easy extended shapes }
  xshapemedium	  = 19;
  xshapehard	  = 26; 	    { different hard extended shapes }

  nkeybindings	  = 8;		    { different keyboard bindings }
  nkeys 	  = 5;		    { number of keys }
  keydrop	  = 1;		    { index for the keys }
  keyleft	  = 2;
  keyright	  = 3;
  keyrotateleft   = 4;
  keyrotateright  = 5;

  norients	  = 3;		    { different orientations }

  ncolors	  = 14; 	    { different colors }
  nstyles	  = 3;		    { different styles }
  nstyletabs	  = 7;		    { different style tables }

  palettesiz	  = 16; 	    { EGA palette size }
  palettemap	  : array [0..palettesiz-1] of byte =
		    ( 0,  7, 63, 47, 49, 25, 27, 10,
		     50, 44, 37, 39, 36, 38, 55, 62);

  ngames	  = 256;	    { number of tournament games }

  rowmin	  = 0;		    { playing field coordinates in pixels }
  rowmax	  = 337;
  colmin	  = 250;
  colmax	  = 392;

  pixelsperblock  = 14; 	    { pixels per block }
  blockcols	  = 10; 	    { columns in blocks }
  maxdepth	  = 24; 	    { max rows in blocks }
  mindepth	  = 5;		    { min rows in blocks }

  initrow	  = 0;		    { initial row and column for mkshape }
  initcol	  = 5;

  left		  = -1; 	    { displacements for movement/rotation }
  right 	  = 1;

  maxheight	  = maxdepth-mindepth; { maximum initial height }
  maxlevel	  = 11; 	    { maximum level }

  filladd	  = 3;		    { constants for fill }
  fillbase	  = 3;

  dropdelay	  = 20; 	    { constants for title drop }
  dropinc	  = 5;

  clearlimit	  = 5;

  bonusempty	  = 500;	    { bonus for an empty pit }
  bonusrowclear   = 3;		    { bonus for clearing a row }
  bonusmultclear  = 2;		    { bonus for clearing multiple rows }
  bonusnext	  = 1;		    { bonus for not using show next shape }
  bonusguide	  = 2;		    { bonus fot not using show guide }
  bonusshadow	  = 1;		    { bonus for not using show shadow }
  bonushidden	  = 3;		    { bonus for using hidden blocks }

  info		  = 0;		    { information element in shape table }

  cleartone	  = 220;	    { row clear tone }
  cleartonedelay  = 10; 	    { row clear tone delay }

  nhiscores	  = 15; 	    { number of high scores }
  hiscorename	  = 'egaint.rec';   { high score file name }
  configname	  = 'egaint.rc';    { configuration file name }


 Type
  displaytype	  = (bw, color, mono, plasma);
  mesgcolors	  = (normal, high);
  bufstr	  = String [32];

  rinfotype	  = Array [1..clearlimit] Of byte;

  hiscorerec	  = Record
		     score	: longint;
		     level	: byte;
		     rowsclear	: word;
		     date	: String [8];
		     time	: String [8];
		     name	: bufstr;
		     version	: String [7]
		    End;


 Const
  shapetab	  : Array [1..nshapes, 0..shapesiz-1, 1..2] Of shortint =
      { bar }	    (((3, 2), ( 0, -1), ( 0,  1), ( 0,	2), ( 0,  0)),
      { tee }	     ((3, 2), ( 0, -1), ( 1,  0), ( 0,	1), ( 0,  0)),
      { box }	     ((3, 3), ( 1,  0), ( 0,  1), ( 1,	1), ( 0,  0)),
      { zig }	     ((3, 3), ( 0, -1), ( 1,  0), ( 1,	1), ( 0,  0)),
      { zag }	     ((3, 3), ( 1, -1), ( 1,  0), ( 0,	1), ( 0,  0)),
      { ell }	     ((3, 3), ( 1, -1), ( 0, -1), ( 0,	1), ( 0,  0)),
      { lel }	     ((3, 3), ( 0, -1), ( 0,  1), ( 1,	1), ( 0,  0)),
   { easy }	     ((0, 0), ( 0,  0), ( 0,  0), ( 0,	0), ( 0,  0)),
		     ((1, 0), ( 0,  1), ( 0,  0), ( 0,	0), ( 0,  0)),
		     ((1, 1), ( 1,  1), ( 0,  0), ( 0,	0), ( 0,  0)),
		     ((2, 1), ( 1,  0), ( 0,  1), ( 0,	0), ( 0,  0)),
		     ((2, 1), ( 0, -1), ( 0,  1), ( 0,	0), ( 0,  0)),
      { 13 }	     ((4, 3), ( 0, -2), ( 0, -1), ( 0,	1), ( 0,  2)),
   { medium }	     ((2, 3), ( 1, -1), ( 1,  1), ( 0,	0), ( 0,  0)),
		     ((2, 4), ( 1, -1), ( 0,  1), ( 0,	0), ( 0,  0)),
		     ((2, 4), ( 0, -1), ( 1,  1), ( 0,	0), ( 0,  0)),
		     ((4, 4), ( 1, -1), ( 0, -1), ( 0,	1), ( 1,  1)),
		     ((4, 4), (-1, -1), (-1,  0), ( 1,	0), (-1,  1)),
      { 19 }	     ((4, 5), ( 0, -1), (-1,  0), ( 1,	0), ( 0,  1)),
   { hard }	     ((4, 5), ( 1, -1), ( 0, -1), (-1,	0), (-1,  1)),
		     ((4, 6), ( 1, -1), ( 0, -1), ( 0,	1), (-1,  1)),
		     ((4, 6), (-1, -1), ( 0, -1), ( 0,	1), ( 1,  1)),
		     ((4, 6), ( 2,  0), ( 1,  0), ( 0,	1), ( 0,  2)),
		     ((3, 7), (-1, -1), ( 1,  0), (-1,	1), ( 0,  0)),
		     ((3, 7), ( 1, -1), ( 2,  0), ( 1,	1), ( 0,  0)),
      { 26 }	     ((4, 7), (-1, -1), ( 1, -1), (-1,	1), ( 1,  1)));

  shapecolortab   : Array [displaytype, 1..ncolors] Of byte =
   { bw }	    ((7, 15, 7, 15, 7, 15, 7, 15,  7, 15,  7, 15,  7, 15),
   { color }	     (2,  3, 4,  5, 6,	7, 8,  9, 10, 11, 12, 13, 14, 15),
   { mono }	     (1,  1, 1,  1, 1,	1, 1,  1,  1,  1,  1,  1,  1,  1),
   { plasma }	     (1,  4, 7,  1, 4,	7, 1,  4,  7,  1,  4,  7,  1,  4));
		   { (1,  7, 1,  7, 1,	7, 1,  7,  1,  7,  1,  7,  1,  7)); }

  mesgcolortab	  : Array [displaytype, mesgcolors] Of byte =
   { bw }	    ((7, 15),
   { color }	     (1,  2),
   { mono }	     (1,  1),
   { plasma }	     (4,  7));

  filltab	  : Array [1..nstyles] Of FillPatternType =
		    (($aa, $55, $aa, $55, $aa, $55, $aa, $55),
		     ($99, $cc, $66, $33, $99, $cc, $66, $33),
		     ($99, $33, $66, $cc, $99, $33, $66, $cc));

  timedelaytab	  : Array [1..maxlevel] Of byte =
		    (10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);

  advancetab	  : Array [1..maxlevel] Of word =
		    (10, 20, 30, 40, 50, 60, 70, 80, 90, 200, 65535);

  xshapetitles	  : Array [1..xshapelevels] Of String [7] =
		    ('Classic',
		     'Easy',
		     'Medium',
		     'Hard');

  styleblocktitles: Array [1..nstyletabs] Of String[20] =
		    ('New',
		     'Classic',
		     'Pumped Full of Drugs',
		     'Barbed Wire Kisses',
		     'Arpeggiator',
		     'Elephant Stone',
		     'Really P.F.D.');

  keynames	  : array [1..nkeybindings, 1..nkeys] of string[2] =
		    (('Sp', 'J', 'L', 'I', 'K'),
		     ('Sp', 'J', 'L', 'K', 'I'),
		     ('Sp', 'H', 'L', 'J', 'K'),
		     ('Sp', 'S', 'F', 'E', 'D'),
		     ('Sp', 'S', 'F', 'D', 'E'),
		     ('Sp', 'A', 'F', 'S', 'D'),
		     ('0',  '4', '6', '8', '5'),
		     ('Sp', 'J', 'L', 'I', 'K'));

  keybindingtab   : array [1..nkeybindings, 1..nkeys] of byte =
    { classic }     ((57, 36, 38, 23, 37),  { sp,   j,	l,  i,	k }
    { russian }      (57, 36, 38, 37, 23),  { sp,   j,	l,  k,	i }
    { berkeley }     (57, 35, 38, 36, 37),  { sp,   h,	l,  j,	k }
    { left-handed }  (57, 31, 33, 18, 32),  { sp,   s,	f,  e,	d }
    { finnish }      (57, 31, 33, 32, 18),  { sp,   s,	f,  d,	e }
    { sf }	     (57, 30, 33, 31, 32),  { sp,   a,	f,  s,	d }
    { arrow }	     (82, 75, 77, 72, 76),  { ins, lf, rt, up,	5 }
    { user-defined } (00, 00, 00, 00, 00));

  keybindingtitles: array [1..nkeybindings] of string[13] =
		    ('Classic',
		     'Russian',
		     'Berkeley',
		     'Left-handed',
		     'Finnish',
		     'San Francisco',
		     'Arrow',
		     'User-defined');

 Var
  shapecolors	  : Array [1..ncolors] Of byte;
  field 	  : Array [0..maxdepth+1, 1..blockcols] Of boolean;
{ fieldshadows	  : Array [1..blockcols] Of boolean; }
  hiscore	  : Array [1..nhiscores] Of hiscorerec;
  styletab	  : Array [1..ncolors, 1..nstyles] Of pointer;
  xstyletabs	  : Array [1..nstyletabs, 1..ncolors, 1..nstyles] Of pointer;
  xshapetab	  : Array [1..nshapes, 0..norients, 1..shapesiz-1, 1..2] Of
		    shortint;
  yshapetab	  : Array [1..nshapes, 0..norients, 1..shapesiz-1, 1..2] Of
		    shortint;
  keybinding	  : array [1..nkeys] of byte;

  buf, buf2, buf3 : String[255];
  colorhigh	  : byte;
  colornormal	  : byte;
  curtain	  : Array [boolean] Of pointer;
  emptyrow	  : pointer;
  fconfig	  : Text;
  fhiscore	  : File of hiscorerec;
  filler	  : pointer;
  graphdriver	  : integer;
  graphmode	  : integer;
  savemode	  : word;
  savenumlock	  : byte;
  scrollptr	  : pointer;
{ shadows	  : pointer; }

  bonus 	  : byte;
  rowsclear	  : word;
  score 	  : longint;
  shapemap	  : byte;
  userpalette	  : palettetype;
  level 	  : byte;

 Const
  endrun	  : boolean	= False;
  page		  : integer	= 0;

  display	  : displaytype = color;
  height	  : byte    = 0;
  initlevel	  : byte    = 5;
  depth 	  : byte    = maxdepth;
  shownext	  : boolean = True;
  showguide	  : boolean = false;
  showshadow	  : boolean = False;
  styleblocks	  : byte    = 0;
  title 	  : boolean = True;
  tones 	  : boolean = True;
  tournament	  : boolean = False;
  tournamentgame  : byte    = 0;
  xshape	  : byte    = 1;
  binding	  : byte    = 1;


 Function gettimer : longint;
  Inline($28/$e4/		    { sub ah,ah }
	 $cd/$1a/		    { int 1ah	}
	 $89/$d0/		    { mov ax,dx }
	 $89/$ca);		    { mov dx,cx }

 procedure numlock(flag : boolean);
  begin
   if flag then
    begin
     savenumlock := mem[$0000:$0417];
     mem[$0000:$0417] := mem[$0000:$0417] or $20
    end
   else
    if savenumlock and $20 = 0 then
     mem[$0000:$0417] := mem[$0000:$0417] and $df
  end;

(*
   if flag then
    inline($1e/ 		    { push ds	      ; save caller's ds }
	   $31/$c0/		    { xor  ax,ax      ; zero ax }
	   $8e/$d8/		    { mov  ds,ax      ; load ds }
	   $a0/$17/$04/ 	    { mov  al,[0417]  ; get keyboard flags }
	   $0c/$20/		    { or   al,20      ; turn on num lock }
	   $a2/$17/$04/ 	    { mov  [0417],al  ; save keyboard flags }
	   $1f) 		    { pop  ds	      ; restore caller's ds }
   else
    inline($1e/ 		    { push ds	      ; save caller's ds }
	   $31/$c0/		    { xor  ax,ax      ; zero ax }
	   $8e/$d8/		    { mov  ds,ax      ; load ds }
	   $a0/$17/$04/ 	    { mov  al,[0417]  ; get keyboard flags }
	   $24/$df/		    { and  al,df      ; turn off num lock }
	   $a2/$17/$04/ 	    { mov  [0417],al  ; save keyboard flags }
	   $1f) 		    { pop  ds	      ; restore caller's ds }
  end; *)

 function getkey : word;
  inline($30/$e4/		    { xor  ah,ah }
	 $cd/$16);		    { int  16 }


 Procedure dographics;
  Begin
   savemode := LastMode;
   DetectGraph(GraphDriver, GraphMode);
   Case GraphDriver Of
    EGAMono:  Begin
	       initgraph(graphdriver, graphmode, '');
	       setgraphmode(egamonohi);
	       display := mono;
	      end;
    EGA:      Begin
	       InitGraph(GraphDriver, GraphMode, '');
	       SetGraphMode(EGAHi)
	      End;
    HercMono: Begin
	       initgraph(graphdriver, graphmode, '');
	       setgraphmode(HercMonoHi);
	       display := mono;
	      End;
    VGA:      Begin
	       InitGraph(GraphDriver, GraphMode, '');
	       SetGraphMode(VGAMed)
	      End;
    Else
     Begin
      WriteLn(id,
 ' requires either an EGA with 256k RAM, VGA, or Hercules graphics adapter.');
      Halt(0)
     End
   End;
   setactivepage(0);
   cleardevice;
   setactivepage(1);
   cleardevice;
  End;


 Procedure dotext;
  Begin
   CloseGraph;
   TextMode(savemode)
  End;


 Procedure fillzero(Var s : bufstr);

  Var
   i		  : integer;

  Begin
   For i := 1 To Length(s) Do
    If s[i] = #32 Then
     s[i] := '0'
  End;


 Procedure placewindow(x1, y1, x2, y2 : integer);
  Begin
   Rectangle(x1, y1, x2, y2);
   Bar(x2+1, y1+8, x2+3, y2);
   Bar(x1+8, y2+1, x2+3, y2+2)
  End;


 Procedure putshape(x, y : integer;
		    s	 : byte;
		    p	 : pointer);

  Var
   i		  : integer;
   xs		  : byte;

  Begin
   xs := shapetab[s, info, 1];
   PutImage(x, y, p^, XORPut);
   For i := 1 To xs Do
    PutImage(x+xshapetab[s, 0, i, 2], y+xshapetab[s, 0, i, 1], p^, XORPut)
  End;


 Procedure init;

  Var
   i, j, isiz	  : integer;
   x, y 	  : integer;

  Procedure abortgraphics;
   Begin
    WriteLn(GraphErrorMsg(GraphResult));
    Halt(0)
   End; {-abortgraphics-}

  Begin {-init-}
   numlock(true);
   Randomize;

   userpalette.colors[0] := -1;

   Assign(fconfig, configname);
   FileMode := 0;			{ read-only }
   Reset(fconfig);
   If IOResult = 0 Then
    Begin
     While Not Eof(fconfig) Do
      Begin
       ReadLn(fconfig, buf3);
       If buf3[1] <> '#' Then
	Begin
	 i := Pos('=', buf3);
	 buf2 := Copy(buf3, 1, i-1);
	 buf := Copy(buf3, i+1, Length(buf3)-i);
       { WriteLn(buf2);
	 WriteLn(buf);
	 ReadLn; }
	 If buf2 = 'display' Then
	  Case buf[1] Of
	   'B', 'b': display := bw;
	   'C', 'c': display := color;
	   'M', 'm': display := mono;
	   'P', 'p': display := plasma
	  End;
	 if buf2 = 'depth' then
	  begin
	   val (buf, i, j);
	   if (j = 0) and (i in [mindepth..maxdepth]) then
	    depth := i;
	  end;
	 If buf2 = 'height' Then
	  Begin
	   Val(buf, i, j);
	   If (j = 0) And (i In [0..2*maxheight]) Then
	    height := i
	  End;
	 If buf2 = 'level' Then
	  Begin
	   Val(buf, i, j);
	   If (j = 0) And (i In [1..maxlevel]) Then
	    initlevel := i
	  End;
	 If buf2 = 'shownext' Then
	  Case buf[1] Of
	   'Y', 'y': shownext := True;
	   'N', 'n': shownext := False
	  End;
	 If buf2 = 'showguide' Then
	  Case buf[1] Of
	   'Y', 'y': showguide := True;
	   'N', 'n': showguide := False
	  End;
       { If buf2 = 'showshadow' Then
	  Case buf[1] Of
	   'Y', 'y': showshadow := False;
	   'N', 'n': showshadow := False
	  End; }
	 If buf2 = 'tournament' Then
	  Case buf[1] Of
	   'Y', 'y': tournament := True;
	   'N', 'n': tournament := False
	  End;
	 If buf2 = 'tournamentgame' Then
	  Begin
	   Val(buf, i, j);
	   If (j = 0) And (i In [0..ngames-1]) Then
	    tournamentgame := i
	  End;
	 If buf2 = 'xshape' Then
	  Case buf[1] Of
	   'C', 'c': xshape := 1;
	   'E', 'e': xshape := 2;
	   'M', 'm': xshape := 3;
	   'H', 'h': xshape := 4
	  End;
	 If buf2 = 'styleblocks' Then
	  Case buf[1] Of
	   'N', 'n': styleblocks := 1;
	   'C', 'c': styleblocks := 2;
	   'P', 'p': styleblocks := 3;
	   'B', 'b': styleblocks := 4;
	   'A', 'a': styleblocks := 5;
	   'E', 'e': styleblocks := 6;
	   'R', 'r': styleblocks := nstyletabs
	  End;
	 If buf2 = 'sound' Then
	  Case buf[1] Of
	   'Y', 'y': tones := True;
	   'N', 'n': tones := False
	  End;
	 If buf2 = 'title' Then
	  Case buf[1] Of
	   'Y', 'y': title := True;
	   'N', 'n': title := False
	  End;

	 if buf2 = 'palette' then
	  begin
	   for x := 0 to palettesiz-2 do
	    begin
	     i := pos (',', buf);
	     if i <> 0 then
	      begin
	       buf3 := copy (buf, 1, i-1);
	       buf := copy (buf, i+1, length (buf)-i);
	       val(buf3, y, j);
	       if (j = 0) and (y in [0..63]) then
		userpalette.colors[x] := y
	       else
		userpalette.colors[0] := -1;
	      end
	     else
	      userpalette.colors[0] := -1;
	    end;
	    val(buf,y,j);
	    if (j = 0) and (y in [0..63]) then
	     userpalette.colors[palettesiz-1] := y
	    else
	     userpalette.colors[0] := -1;
	  end;

	 if buf2 = 'keybinding' then
	  Case buf[1] Of
	   'C', 'c': binding := 1;
	   'R', 'r': binding := 2;
	   'B', 'b': binding := 3;
	   'L', 'l': binding := 4;
	   'F', 'f': binding := 5;
	   'S', 's': binding := 6;
	   'A', 'a': binding := 7;
	   'U', 'u': binding := 8;
	   '0'..'9': begin
		      binding := 8;
		      for x := 1 to nkeys-1 do
		       begin
			i := pos (',', buf);
			if i <> 0 then
			 begin
			  buf3 := copy(buf, 1, i-1);
			  buf := copy(buf, i+1, length(buf)-i);
			  val(buf3, y, j);
			  if (j = 0) and (y in [0..255]) then
			   keybindingtab[nkeybindings, x] := y
			  else
			    keybindingtab[nkeybindings, 1] := 0;
			 end
			else
			 keybindingtab[nkeybindings, 1] := 0;
		       end;
		      val(buf, y, j);
		      if (j = 0) and (y in [0..255]) then
		       keybindingtab[nkeybindings, nkeys] := y
		      else
		       keybindingtab[nkeybindings, 1] := 0;
		     end
	  end
	End
      End;
     Close(fconfig)
    End;

   If ParamCount > 0 Then
    Begin
     buf := Copy(ParamStr(1), 1, 1);
     Case buf[1] Of
      'B', 'b': display := bw;
      'C', 'c': display := color;
      'M', 'm': display := mono;
      'P', 'p': display := plasma
     End
    End;

   If RegisterBGIdriver(@EGAVGADriver) < 0 Then
    abortgraphics;
   if registerbgidriver(@hercdriver) < 0 then
    abortgraphics;

   If RegisterBGIfont(@SansSerifFontProc) < 0 Then
    abortgraphics;
   If RegisterBGIfont(@SmallFontProc) < 0 Then
    abortgraphics;

   dographics;

   For i := 1 To nshapes Do
    For j := 1 To shapesiz-1 Do
     Begin
      xshapetab[i, 0, j, 1] :=	pixelsperblock*shapetab[i, j, 1];
      yshapetab[i, 0, j, 1] :=	shapetab[i, j, 1];
      xshapetab[i, 0, j, 2] :=	pixelsperblock*shapetab[i, j, 2];
      yshapetab[i, 0, j, 2] :=	shapetab[i, j, 2];
      xshapetab[i, 1, j, 1] :=	pixelsperblock*shapetab[i, j, 2];
      yshapetab[i, 1, j, 1] :=	shapetab[i, j, 2];
      xshapetab[i, 1, j, 2] := -pixelsperblock*shapetab[i, j, 1];
      yshapetab[i, 1, j, 2] := -shapetab[i, j, 1];
      xshapetab[i, 2, j, 1] := -pixelsperblock*shapetab[i, j, 1];
      yshapetab[i, 2, j, 1] := -shapetab[i, j, 1];
      xshapetab[i, 2, j, 2] := -pixelsperblock*shapetab[i, j, 2];
      yshapetab[i, 2, j, 2] := -shapetab[i, j, 2];
      xshapetab[i, 3, j, 1] := -pixelsperblock*shapetab[i, j, 2];
      yshapetab[i, 3, j, 1] := -shapetab[i, j, 2];
      xshapetab[i, 3, j, 2] :=	pixelsperblock*shapetab[i, j, 1];
      yshapetab[i, 3, j, 2] :=	shapetab[i, j, 1]
     End;

   For i := 1 To ncolors Do
    shapecolors[i] := shapecolortab[display, i];

   colornormal := mesgcolortab[display, normal];
   colorhigh   := mesgcolortab[display, high];

   FillChar(hiscore, SizeOf(hiscore), 0);
   i := 1;
   Assign(fhiscore, hiscorename);
   FileMode := 0;			{ read-only }
   Reset(fhiscore);
   If IOResult = 0 Then
    Begin
     While (i <= nhiscores) And (Not Eof(fhiscore)) Do
      Begin
       Read(fhiscore, hiscore[i]);
       Inc(i)
      End;
     Close(fhiscore)
    End;

   SetVisualPage(page);
   page := 1-page;
   SetActivePage(page);

   GetMem(scrollptr, ImageSize(colmin+1, rowmin, colmax-1,
    rowmax+pixelsperblock));

   getmem(emptyrow, ImageSize(colmin+1, rowmin, colmax-1,
    rowmin+pixelsperblock+1));
   isiz := ImageSize(colmin+1, rowmin, colmax-1, rowmin+pixelsperblock);

 { isiz := ImageSize(0, 0, pixelsperblock, pixelsperblock);
   SetColor(colorhigh);
   SetFillPattern(filltab[1], colornormal);
   Bar(0, 0, pixelsperblock, pixelsperblock Shr 1);
   GetMem(shadows, isiz);
   GetImage(0, 0, pixelsperblock, pixelsperblock Shr 1, shadows^);
   PutImage(0, 0, shadows^, XORPut); }

   isiz := ImageSize(0, 0, pixelsperblock, pixelsperblock);
   SetColor(colornormal);
   SetFillStyle(SolidFill, colornormal);
   Bar(1, 1, pixelsperblock-1, pixelsperblock-1);
   SetColor(Black);
   Rectangle(3, 3, pixelsperblock-3, pixelsperblock-3);
   Line(1, 1, 3, 3);
   Line(1, pixelsperblock-1, 3, pixelsperblock-3);
   Line(pixelsperblock-1, 1, pixelsperblock-3, 3);
   Line(pixelsperblock-1, pixelsperblock-1, pixelsperblock-3,
	pixelsperblock-3);

   For i := 1 To ncolors Do		  { new }
    For j := 1 To nstyles Do
     Begin
      SetFillPattern(filltab[j], shapecolors[i]);
      Bar(4, 4, pixelsperblock-4, pixelsperblock-4);
      GetMem(xstyletabs[1, i, j], isiz);
      GetImage(0, 0, pixelsperblock, pixelsperblock, xstyletabs[1, i, j]^)
     End;

   For i := 1 To ncolors Do		  { pumped full of drugs }
    For j := 1 To nstyles Do
     Begin
      SetFillPattern(filltab[Random(nstyles)+1],
		     shapecolors[Random(ncolors)+1]);
      Bar(4, 4, 7, 7);
      SetFillPattern(filltab[Random(nstyles)+1],
		     shapecolors[Random(ncolors)+1]);
      Bar(7, 4, 10, 7);
      SetFillPattern(filltab[Random(nstyles)+1],
		     shapecolors[Random(ncolors)+1]);
      Bar(4, 7, 7, 10);
      SetFillPattern(filltab[Random(nstyles)+1],
		     shapecolors[Random(ncolors)+1]);
      Bar(7, 7, 10, 10);
      GetMem(xstyletabs[3, i, j], isiz);
      GetImage(0, 0, pixelsperblock, pixelsperblock, xstyletabs[3, i, j]^)
     End;

  if display = mono then
   begin
    for i := 1 to ncolors do		    { barbed wire kisses }
     for j := 1 to nstyles do
      begin
       for x := 4 to pixelsperblock-4 do
	for y := 4 to pixelsperblock-4 do
	 begin
	  if random(3) > 0 then
	   putpixel(x, y, shapecolors[i])
	  else
	   putpixel(x, y, 0);
	 end; { for }
	GetMem(xstyletabs[4, i, j], isiz);
	GetImage(0, 0, pixelsperblock, pixelsperblock, xstyletabs[4, i, j]^)
       End
   end
  else
   begin
    for i := 1 to ncolors do
     for j := 1 to nstyles do
      begin
       for x := 4 to pixelsperblock-4 do
	for y := 4 to pixelsperblock-4 do
	 begin
	  if random(2) = 0 then
	   putpixel(x, y, shapecolors[i])
	  else
	   putpixel(x, y, shapecolors[random(ncolors)+1])
	 end; { for }
	GetMem(xstyletabs[4, i, j], isiz);
	GetImage(0, 0, pixelsperblock, pixelsperblock, xstyletabs[4, i, j]^)
       End
   end;

   SetFillPattern(filltab[1], colornormal);
   Bar(4, 4, pixelsperblock-4, pixelsperblock-4);
   GetMem(filler, isiz);
   GetImage(0, 0, pixelsperblock, pixelsperblock, filler^);
   PutImage(0, 0, filler^, XORPut);

   For i := 1 To ncolors Do		{ classic }
    Begin
     SetColor(shapecolors[i]);
     For j := 1 To nstyles Do
      Begin
       SetFillPattern(filltab[j], shapecolors[i]);
       Rectangle(1, 1, pixelsperblock-1, pixelsperblock-1);
       Bar(3, 3, pixelsperblock-3, pixelsperblock-3);
       GetMem(xstyletabs[2, i, j], isiz);
       GetImage(0, 0, pixelsperblock, pixelsperblock, xstyletabs[2, i, j]^)
      End
    End;

   For i := 1 To ncolors Do		{ arpeggiator }
    Begin
     SetColor(shapecolors[i]);
     For j := 1 To nstyles Do
      Begin
       SetFillPattern(filltab[j], shapecolors[i]);
       bar(1, 1, pixelsperblock-1, pixelsperblock-1);
       GetMem(xstyletabs[5, i, j], isiz);
       GetImage(0, 0, pixelsperblock, pixelsperblock, xstyletabs[5, i, j]^)
      End
    End;

  if display = mono then
   begin
    for i := 1 to ncolors do		  { elephant stone }
     for j := 1 to nstyles do
      begin
       for x := 1 to pixelsperblock-1 do
	for y := 1 to pixelsperblock-1 do
	 begin
	  if random(3) > 0 then
	   putpixel(x, y, shapecolors[i])
	  else
	   putpixel(x, y, 0);
	 end; { for }
	getMem(xstyletabs[6, i, j], isiz);
	getImage(0, 0, pixelsperblock, pixelsperblock, xstyletabs[6, i, j]^)
       end
   end
  else
   begin
    for i := 1 to ncolors do		  { elephant stone }
     for j := 1 to nstyles do
      begin
       for x := 1 to pixelsperblock-1 do
	for y := 1 to pixelsperblock-1 do
	 begin
	  if random(2) = 0 then
	   putpixel(x, y, shapecolors[i])
	  else
	   putpixel(x, y, shapecolors[random(ncolors)+1])
	 end; { for }
	getMem(xstyletabs[6, i, j], isiz);
	getImage(0, 0, pixelsperblock, pixelsperblock, xstyletabs[6, i, j]^)
       end;
    end;

   SetColor(colorhigh);
   SetFillPattern(filltab[2], colornormal);
   Bar(1, 1, pixelsperblock-1, pixelsperblock-1);
   GetMem(curtain[true], isiz);
   GetImage(0, 0, pixelsperblock, pixelsperblock, curtain[true]^);

   SetFillPattern(filltab[3], colornormal);
   Bar(1, 1, pixelsperblock-1, pixelsperblock-1);
   GetMem(curtain[false], isiz);
   GetImage(0, 0, pixelsperblock, pixelsperblock, curtain[false]^);
   PutImage(0, 0, curtain[false]^, XORPut);

   For i := 1 To ncolors Do
    For j := 1 To nstyles Do
     xstyletabs[nstyletabs, i, j] := xstyletabs[Random(nstyletabs-1)+1, i, j];
{				       Random(ncolors)+1,
				       Random(nstyles)+1] }

   if display = color then
    begin
     userpalette.size := palettesiz;
     if userpalette.colors[0] = -1 then
      for i := 0 to palettesiz-1 do
       userpalette.colors[i] := palettemap[i];
     setallpalette(userpalette)
    end
  End; {-init-}


 Procedure drawtitle;

  Const
   titlesiz	  = 95;
   titletab	  : Array [1..titlesiz, 1..2] Of integer =
		    (( 75,  57), ( 75,	71), ( 75, 85), ( 75, 99),
		      ( 75, 113), ( 75, 127), ( 75, 141),
		     ( 89,  57), ( 89, 99), ( 89, 141),
		     (103,  57), (103, 99), (103, 141),
		     (117,  57), (117, 99), (117, 141),
		     (131,  57), (131, 141),

		     (159,  71), (159, 85), (159, 99), (159, 113),
		      (159, 127),
		     (173,  57), (173, 141),
		     (187,  57), (187, 141),
		     (201,  57), (201, 99), (201, 141),
		     (215,  71), (215, 99), (215, 113), (215, 127),

		     (243,  71), (243, 85), (243, 99), (243, 113),
		      (243, 127), (243, 141),
		     (257,  57), (257, 99),
		     (271,  57), (271, 99),
		     (285,  57), (285, 99),
		     (299,  71), (299, 85), (299, 99), (299, 113),
		      (299, 127), (299, 141),

		     (327,  57), (327, 141),
		     (341,  57), (341, 141),
		     (355,  57), (355,	71), (355, 85), (355, 99),
		      (355, 113), (355, 127), (355, 141),
		     (369,  57), (369, 141),
		     (383,  57), (383, 141),

		     (411,  57), (411,	71), (411, 85), (411, 99),
		      (411, 113), (411, 127), (411, 141),
		     (425,  71),
		     (439, 85),
		     (453, 99),
		     (467,  57), (467,	71), (467, 85), (467, 99),
		      (467, 113), (467, 127), (467, 141),

		     (495,  57),
		     (509,  57),
		     (523,  57), (523,	71), (523, 85), (523, 99),
		      (523, 113), (523, 127), (523, 141),
		     (537,  57),
		     (551,  57));

  Var
   test 	  : Array [1..titlesiz] Of boolean;
   ch		  : word;
   i, j, c, s	  : integer;
   x, y1, y2	  : integer;
   p		  : pointer;

  Begin {-drawtitle-}
   FillChar(test, SizeOf(test), 0);

   If styleblocks = 0 Then
    styleblocks := Random(nstyletabs-1)+1;
   s := 1;

   if title then
    begin
     For i := 1 To titlesiz Do
      Begin
       Repeat
	j := Random(titlesiz)+1
       Until Not test[j];
       c := Random(ncolors)+1;
       If styleblocks = 3 Then
	s := Random(nstyles)+1;
       x := titletab[j, 1];
       If KeyPressed Then
	y1 := titletab[j, 2]
       Else
	Begin
	 y1 := 0;
	 y2 := dropinc
	End;
       p := xstyletabs[styleblocks, c, s];
       PutImage(x, y1, p^, XORPut);
       SetVisualPage(page);
       page := 1-page;
       SetActivePage(page);

       While (Not KeyPressed) And (y2 < titletab[j, 2]) Do
	Begin
	 PutImage(x, y2, p^, XORPut);
	 Delay(dropdelay);
	 SetVisualPage(page);
	 page := 1-page;
	 SetActivePage(page);
	 PutImage(x, y1, p^, XORPut);
	 y1 := y2;
	 Inc(y2, dropinc)
	End;

       PutImage(x, titletab[j, 2], p^, XORPut);
       SetVisualPage(page);
       page := 1-page;
       SetActivePage(page);

       PutImage(x, y1, p^, XORPut);
       PutImage(x, titletab[j, 2], p^, XORPut);
       test[j] := True
      End;
     While KeyPressed Do
      ch := getkey;

     SetTextJustify(CenterText, TopText);
     SetColor(colorhigh);
     SetTextStyle(SansSerifFont, HorizDir, 4);
     OutTextXY(320, 7, 'Welcome to version '+version+' of');
     OutTextXY(320, 162, copyright);

     SetTextStyle(SmallFont, HorizDir, 4);
     OutTextXY(320, 215,
  'This program comes with ABSOLUTELY NO WARRANTY; see the accompanying GNU '+
  'General Public License for full');
     OutTextXY(320, 227,
  'details.  You should have received a copy along with this program (see the '+
  'file COPYING).  If not, write to:');
     OutTextXY(320, 239,
  'Free Software Foundation, Inc., 675 Massachusetts Avenue, Cambridge, '+
  'Massachusetts 02139');

     OutTextXY(320, 323,
  'Eric Ng, 1906 Milvia Street, Berkeley, California 94704');
     OutTextXY(320, 335, 'Internet: erc@irss.njit.edu');

     SetColor(colornormal);
     OutTextXY(160, 257, 'To obtain the full source code and/or the');
     OutTextXY(160, 269, 'latest version of this program, call');
     OutTextXY(160, 305, 'or see the included file GETTING.');

     OutTextXY(480, 257, 'Requirements:  IBM PC, PS/2, or 100%');
     OutTextXY(480, 269, 'compatible (8 MHz or faster CPU is strongly');
     OutTextXY(480, 281, 'recommended); an EGA with 256k RAM, VGA,');
     OutTextXY(480, 293, 'Hercules graphics adapter; and 256k free');
     OutTextXY(480, 305, 'system RAM.');

     SetColor(colorhigh);
     OutTextXY(160, 281, 'The Odyssey +1 201 984 6574');
     OutTextXY(160, 293, 'The PC GFX Exchange +1 415 337 5416');
   { OutTextXY(160, 293, 'The Bandersnatch +1 201 766-3801') }
    end;

   SetVisualPage(page);
   page := 1-page;
   SetActivePage(page);
   ClearDevice;

   if title then
    begin
     Repeat Until KeyPressed;
     Repeat
      ch := getkey
     Until Not KeyPressed
    end
  End; {-drawtitle-}

 procedure getkeybindings;

  procedure drawkeybindings;
   begin
    SetTextJustify(CenterText, TopText);
    SetColor(colorhigh);
    SetTextStyle(SansSerifFont, HorizDir, 4);
    OutTextXY(320, 2, id+' '+version);

    SetColor(colornormal);
    SetTextStyle(DefaultFont, HorizDir, 1);
    OutTextXY(320, 40, 'Key Bindings');
    SetFillStyle(SolidFill, colornormal);
    placewindow(237, 60, 403, 132);

    SetTextStyle(SmallFont, HorizDir, 4);
    outtextxy(320, 86, 'Press the key for');
   end;

  procedure getgetkey(n : integer);
   var
    ch : word;
    i  : integer;

   begin
    repeat
     repeat
      ch := getkey
     until lo(ch) in [32..126];
     i := 1;
     while (keybindingtab[nkeybindings, i] <> hi(ch)) and (i < n) do
      inc(i);
     if i = n then
      begin
       keybindingtab[nkeybindings, n] := hi(ch);
       if tones then
	begin
	 Sound(cleartone);
	 Delay(cleartonedelay);
	 NoSound
	end
      end
    until i = n
   end; {-getgetkey-}

  begin {-getkeybindings-}
   drawkeybindings;
   setvisualpage(page);

   setcolor(colorhigh); outtextxy(320, 98, 'Drop');
   getgetkey(keydrop);
   setcolor(black); outtextxy(320, 98, 'Drop');

   setcolor(colorhigh); outtextxy(320, 98, 'Move Left');
   getgetkey(keyleft);
   setcolor(black); outtextxy(320, 98, 'Move Left');

   setcolor(colorhigh); outtextxy(320, 98, 'Move Right');
   getgetkey(keyright);
   setcolor(black); outtextxy(320, 98, 'Move Right');

   setcolor(colorhigh); outtextxy(320, 98, 'Rotate Left');
   getgetkey(keyrotateleft);
   setcolor(black); outtextxy(320, 98, 'Rotate Left');

   setcolor(colorhigh); outtextxy(320, 98, 'Rotate Right');
   getgetkey(keyrotateright);
   setcolor(black); outtextxy(320, 98, 'Rotate Right')
  end; {-getkeybindings-}

 Procedure initgame;

  Var
   i, j 	  : integer;

  Procedure getoptions;

   Const
    noptions	  = 10;
    optiontitles  : Array [1..noptions] Of String [22] =
		    ('Tournament Game',
		     'Tournament Game Number',
		     'Initial Level',
		     'Initial Height',
		     'Show Next',
		     'Extended Shapes',
		     'Block Style',
		     'Key Bindings',
		     'Pit Depth',
		     'Show Guide');
    optiony	  = 80;
    optionyinc	  = 22;

   Var
    done	  : boolean;
    o		  : byte;
    bigheight	  : byte;
    ch		  : word;

   Procedure drawoptions;

    Var
     i		  : integer;

    Begin {-drawoptions-}
     SetTextJustify(CenterText, TopText);
     SetColor(colorhigh);
     SetTextStyle(SansSerifFont, HorizDir, 4);
     OutTextXY(320, 2, id+' '+version);

     SetColor(colornormal);
     SetTextStyle(DefaultFont, HorizDir, 1);
     OutTextXY(320, 40, 'Options');
     OutTextXY(320, 330,
'Press the arrow keys to move, Enter to rotate, and the Space Bar when done.');
     SetFillStyle(SolidFill, colornormal);
     placewindow(150, 65, 490, 307);

     SetTextJustify(LeftText, TopText);
     For i := 1 To noptions Do
      OutTextXY(200, optiony+(optionyinc*(i-1))+3, optiontitles[i])
    End; {-drawoptions-}

   Procedure showflag(f : boolean;
		      y : integer);
    Begin
     If f Then
      OutTextXY(440, optiony+(optionyinc*(y-1)), 'Yes')
     Else
      OutTextXY(440, optiony+(optionyinc*(y-1)), 'No')
    End; {-showflag-}

   Procedure showoption(o : byte);
    Begin
     Case o Of
      1: showflag(tournament, o);
      2: Begin
	  Str(tournamentgame, buf);
	  OutTextXY(440, optiony+(optionyinc*(o-1)), buf)
	 End;
      3: Begin
	  Str(level, buf);
	  OutTextXY(440, optiony+(optionyinc*(o-1)), buf)
	 End;
      4: Begin
	  If height > maxheight Then
	    begin
	     str(height-maxheight, buf);
	     buf := 'Hidden '+buf
	    end
	  Else
	   Str(height, buf);
	  OutTextXY(440, optiony+(optionyinc*(o-1)), buf)
	 End;
      5: showflag(shownext, o);
      6: OutTextXY(440, optiony+(optionyinc*(o-1)), xshapetitles[xshape]);
      7: OutTextXY(440, optiony+(optionyinc*(o-1)), styleblocktitles[styleblocks]);
      8: OutTextXY(440, optiony+(optionyinc*(o-1)), keybindingtitles[binding]);
      9: begin
	  str(depth, buf);
	  outtextxy(440, optiony+(optionyinc*(o-1)), buf);
	 end;
     10: showflag(showguide, o);
     End
    End; {-showoptions-}

   Procedure rotateopt(o : byte);
    Begin
     SetTextJustify(RightText, TopText);
     SetTextStyle(SmallFont, HorizDir, 4);
     SetColor(Black);
     showoption(o);
     Case o Of
      1: tournament	:= Not tournament;
      2: tournamentgame := (tournamentgame+1) Mod ngames;
      3: level		:= (level Mod maxlevel)+1;
      4: height := (height+1) Mod ((2*maxheight)+1);
      5: shownext	:= Not shownext;
      6: xshape 	:= (xshape Mod xshapelevels)+1;
      7: styleblocks	:= (styleblocks Mod nstyletabs)+1;
      8: begin
	  binding	:= (binding mod nkeybindings)+1;
	  if binding = nkeybindings then
	   keybindingtab[nkeybindings, 1] := 0
	 end;
      9: begin
	  inc(depth);
	  if depth > maxdepth then depth := mindepth;
	 end;
     10: showguide := not showguide;
     End;
     SetColor(colorhigh);
     showoption(o)
    End; {-rotateopt-}

   Begin {-getoptions-}
    drawoptions;
    level := initlevel;
    SetTextJustify(RightText, TopText);
    SetTextStyle(SmallFont, HorizDir, 4);
    SetColor(colorhigh);
    For o := 1 To noptions Do
     showoption(o);
    SetVisualPage(page);

    done := False;
    o	 := 1;
    Repeat
     SetTextJustify(LeftText, TopText);
     SetTextStyle(DefaultFont, HorizDir, 1);
     SetColor(colorhigh);
     OutTextXY(200, optiony+(optionyinc*(o-1))+3, optiontitles[o]);
     OutTextXY(190, optiony+(optionyinc*(o-1))+3, #254);

     Repeat Until KeyPressed;
     ch := getkey;
     Case hi(ch) of
		       1: Begin 		    { escape }
			   done   := True;
			   endrun := True
			  End;
		      57: done := True; 	    { space }
	  35, 36, 72, 75: begin 		    { H J up left }
			   SetColor(colornormal);
			   OutTextXY(200, optiony+(optionyinc*(o-1))+3, optiontitles[o]);
			   SetColor(0);
			   OutTextXY(190, optiony+(optionyinc*(o-1))+3, #254);
			   If o < 2 Then
			    o := noptions
			   Else
			    Dec(o)
			  End;
	      23, 28, 37: rotateopt(o); 	    { I enter K }
	      38, 77, 80: begin 		    { L right down }
			   SetColor(colornormal);
			   OutTextXY(200, optiony+(optionyinc*(o-1))+3, optiontitles[o]);
			   SetColor(0);
			   OutTextXY(190, optiony+(optionyinc*(o-1))+3, #254);
			   If o > noptions-1 Then
			    o := 1
			   Else
			    Inc(o)
			  End
     End
    Until done;

    page := 1-page;
    SetActivePage(page);
    ClearDevice;
   End; {-getoptions-}

  Procedure fillfield(h : byte);

   Var
    i, j	  : integer;
    k		  : byte;

   Begin {-fillfield-}
    For i := depth DownTo depth-(h-1) Do
     Begin
      k := Random(filladd)+fillbase;
      For j := 1 To k Do
       field[i, Random(blockcols)+1] := True
     End
   End; {-fillfield-}

  Begin {-initgame-}
   getoptions;

   FillChar(field, SizeOf(field)-blockcols, 0);
   FillChar(field[depth+1, 1], blockcols, 1);
 { FillChar(fieldshadows, SizeOf(fieldshadows), 0); }

   If tournament Then
    RandSeed := tournamentgame;

   If height <> 0 Then
    Begin
     If height > maxheight Then
      begin
       if depth-(height-maxheight) < mindepth then
	height := (depth-mindepth)+maxheight;
       fillfield(height-maxheight);
       bonus := (height-maxheight)+bonushidden
      end
     Else
      Begin
       if depth-height < mindepth then
	height := depth-mindepth;
       fillfield(height);
       bonus := height
      End
    End
   Else
    bonus := 0;
   If Not shownext Then
    Inc(bonus, bonusnext);
   if not showguide then
    inc(bonus, bonusguide);
   If Not showshadow Then
    Inc(bonus, bonusshadow);
   inc(bonus, (maxdepth-depth)*2);

   rowsclear := 0;
   score     := 0;

   Case xshape Of
    1: shapemap := xshapeclassic;
    2: shapemap := xshapeeasy;
    3: shapemap := xshapemedium;
    4: shapemap := xshapehard
   End;

   Move(xstyletabs[styleblocks], styletab, SizeOf(styletab));
   if not endrun then
    if binding = nkeybindings then
     begin
      if keybindingtab[nkeybindings, 1] = 0 then
       getkeybindings
     end
    else
     fillchar(keybindingtab[nkeybindings], sizeof(keybinding), 0);
   move(keybindingtab[binding], keybinding, sizeof(keybinding))
  End; {-initgame-}

 procedure drawguide(c:byte);
  var i:integer;
  begin
   setcolor(c);
   setlinestyle(userbitln,$aaaa,normwidth);
   for i := 1 to blockcols-1 do
    line(colmin+(pixelsperblock*i)+1, rowmin,
     colmin+(pixelsperblock*i)+1, rowmin+(pixelsperblock*depth));
   setlinestyle(solidln,0,normwidth)
  end;

 Procedure drawscreen;

  Procedure drawfieldwin;

   Var
    rowmaxpel	   : integer;
    colminpel	   : integer;
    colmaxpel	   : integer;
    i		   : integer;

   Begin {-drawfieldwin-}
    rowmaxpel := getmaxy;
    colminpel := colmin-pixelsperblock;
    colmaxpel := colmax+pixelsperblock;

    SetColor(colornormal);
    SetFillPattern(filltab[1], colornormal);
    Bar(colminpel, rowmin, colmin, rowmaxpel);
    Bar(colmin, rowmax, colmax, rowmaxpel);
    Bar(colmax, rowmin, colmaxpel, rowmaxpel);
    Line(colminpel, rowmin, colminpel, rowmaxpel);
    Line(colmin, rowmin, colmin, rowmax);
    Line(colmax, rowmin, colmax, rowmax);
    Line(colmaxpel, rowmin, colmaxpel, rowmaxpel);
    Line(colminpel, rowmin, colmin, rowmin);
    Line(colmin, rowmax, colmax, rowmax);
    Line(colmax, rowmin, colmaxpel, rowmin);
    Line(colminpel, rowmaxpel, colmaxpel, rowmaxpel);

    if depth <> maxdepth then
     begin
      setfillpattern(filltab[1], colornormal);
      bar(colmin+2, rowmin+(pixelsperblock*depth)+1, colmax-2,
       rowmin+(pixelsperblock*maxdepth)-1);
    end;

    if showguide then
     drawguide(colornormal)
   End; {-drawfieldwin-}

  Procedure drawnextwin;
   Begin
    SetColor(colornormal);
    SetFillStyle(SolidFill, colornormal);
    placewindow(35, 16, 201, 126);

    SetTextStyle(DefaultFont, HorizDir, 1);
    settextjustify(centertext, toptext);
    OutTextXY(118, 114, 'Next')
   End;

  Procedure drawscorewin;
   Begin
    SetColor(colornormal);
    SetFillStyle(SolidFill, colornormal);
    placewindow(439, 16, 605, 126);

    SetColor(colorhigh);
    SetTextStyle(SansSerifFont, HorizDir, 4);
    SetTextJustify(CenterText, TopText);
    OutTextXY(522, 21, id);

    SetColor(colornormal);
    SetTextStyle(SmallFont, HorizDir, 4);
    OutTextXY(522, 60, copyright);

    SetTextStyle(DefaultFont, HorizDir, 1);
    SetTextJustify(LeftText, TopText);
    OutTextXY(466, 75, 'Score:');
    OutTextXY(466, 87, 'Value:');
    OutTextXY(466, 99, 'Level:');
    OutTextXY(466, 111, ' Rows:');
   End; {-drawscorewin-}

  Procedure drawhelpwin;
   Begin
    SetColor(colornormal);
    SetFillStyle(SolidFill, colornormal);
    placewindow(35, 224, 201, 334);
    placewindow(439, 224, 605, 334);

    SetColor(colorhigh);
    SetTextStyle(DefaultFont, HorizDir, 1);
    OutTextXY(58, 246, keynames[binding, keyleft]);
    OutTextXY(58, 258, keynames[binding, keyrotateleft]);
    OutTextXY(58, 270, keynames[binding, keyrotateright]);
    OutTextXY(58, 282, keynames[binding, keyright]);
    OutTextXY(58, 294, keynames[binding, keydrop]);
    OutTextXY(58, 306, 'Esc');
    OutTextXY(462, 246, '^B');
    OutTextXY(462, 258, '^L');
    OutTextXY(462, 270, '^N');
    OutTextXY(462, 282, '^S');
    OutTextXY(462, 294, '^X');
    OutTextXY(462, 306, '^\');

    SetColor(colornormal);
    SetTextStyle(SmallFont, HorizDir, 4);
    OutTextXY(90, 243, 'move left');
    OutTextXY(90, 255, 'rotate left');
    OutTextXY(90, 267, 'rotate right');
    OutTextXY(90, 279, 'move right');
    OutTextXY(90, 291, 'drop');
    OutTextXY(90, 303, 'pause/quit');
    OutTextXY(494, 243, 'block style');
    OutTextXY(494, 255, 'change level');
    OutTextXY(494, 267, 'show next');
    OutTextXY(494, 279, 'toggle sound');
    OutTextXY(494, 291, 'extended shapes');
    OutTextXY(494, 303, 'quick exit')
   End; {-drawhelpwin-}

  Procedure refill;

   Var
    i, j	  : integer;

   Begin {-refill-}
    For i := depth DownTo depth-(height-1) Do
     For j := 1 To blockcols Do
      If field[i, j] Then
       PutImage(colmin+(pixelsperblock*(j-1))+1,
		rowmin+(pixelsperblock*(i-1)), filler^, XORPut)
   End; {-refill-}

  Begin {-drawscreen-}
   ClearDevice;
   drawfieldwin;
   GetImage(colmin+1, rowmin, colmax-1, rowmin+pixelsperblock+1, emptyrow^);
   drawnextwin;
   drawscorewin;
   drawhelpwin;
   If height In [1..maxheight] Then
    refill;

   SetVisualPage(page);
   page := 1-page;
   SetActivePage(page);

   ClearDevice;
   drawfieldwin;
   drawnextwin;
   drawscorewin;
   drawhelpwin;
   If height In [1..maxheight] Then
    refill;
  End; {-drawscreen-}

 procedure cleanup;
  forward;

 Procedure play;

  Var
   dropped	  : boolean;
   endgame	  : boolean;
   shape	  : byte;
   orient	  : byte;
   row, col	  : byte;
   color	  : byte;
   style	  : byte;
   ch		  : word;
   k		  : byte;
   t, tdelay	  : longint;

   nextshape	  : byte;
   nextcolor	  : byte;
   nextstyle	  : byte;

   xsize	  : byte;
   xvalue	  : integer;

   oldscore	  : longint;
   oldxvalue	  : integer;
   oldlevel	  : byte;
   oldxshape	  : byte;
   oldrowsclear   : word;

   i, j 	  : integer;
   r, c 	  : byte;

{ procedure fake;
   var
    a, b, c, d	  : pointer;
    i, j	  : integer;
    z		  : bufstr;

   begin
    i := imagesize(0, 0, getmaxx, getmaxy div 2);
    j := imagesize(0, (getmaxy div 2)+1, getmaxx, getmaxy);
    getmem(a, i); getmem(c, i);
    getmem(b, j); getmem(d, j);
    getimage(0, 0, getmaxx, getmaxy div 2, a^);
    getimage(0, (getmaxy div 2)+1, getmaxx, getmaxy, b^);
    setactivepage(1-page);
    getimage(0, 0, getmaxx, getmaxy div 2, c^);
    getimage(0, (getmaxy div 2)+1, getmaxx, getmaxy, d^);
    textmode(c80);
    repeat
     write('C:>');
     readln(z)
    until z = 'exit';
    dographics;
    SetTextStyle(SmallFont, HorizDir, 4);
    setvisualpage(page);
    setactivepage(1-page);
    putimage(0, 0, c^, normalput);
    putimage(0, (getmaxy div 2)+1, d^, normalput);
    setvisualpage(1-page);
    setactivepage(page);
    putimage(0, 0, a^, normalput);
    putimage(0, (getmaxy div 2)+1, b^, normalput);
    freemem(a, i); freemem(b, j); freemem(c, i); freemem(d, j)
   end; }

  Procedure scrolldown(rclr  : byte;
		       var r : rinfotype);

   Var
    rz		  : Array [1..clearlimit] Of integer;
    i, j	  : integer;

   Begin {-scrolldown-}
    For i := 1 To rclr Do
     rz[i] := pixelsperblock*(r[i]-1);

    For i := 1 To rclr Do
     Begin
      GetImage(colmin+1, rowmin, colmax-1, rz[i], scrollptr^);
      PutImage(colmin+1, rowmin, emptyrow^, NormalPut);
      PutImage(colmin+1, rowmin+pixelsperblock, scrollptr^, NormalPut);
      if tones then
       begin
	Sound(cleartone);
	Delay(cleartonedelay);
	NoSound
       end;
      SetVisualPage(page);
      page := 1-page;
      SetActivePage(page);
      PutImage(colmin+1, rowmin, emptyrow^, NormalPut);
      PutImage(colmin+1, rowmin+pixelsperblock, scrollptr^, NormalPut)
     End
   End; {-scrolldown-}

  Procedure drawshape;

   Var
    i		  : integer;
    x, y, x1, y1  : integer;
    p		  : pointer;

   Begin {-drawshape-}
  { If showshadow Then
     FillChar(fieldshadows, SizeOf(fieldshadows), 0); }
    x := colmin+(pixelsperblock*(col-1))+1;
    y := rowmin+(pixelsperblock*(row-1));
    p := styletab[color, style];

    PutImage(x, y, p^, XORPut);
  { If showshadow Then
     Begin
      PutImage(x, rowmax+1, shadows^, XORPut);
      fieldshadows[col] := True
     End; }
    For i := 1 To xsize Do
     Begin
      x1 := x+xshapetab[shape, orient, i, 2];
      y1 := y+xshapetab[shape, orient, i, 1];
      If (y1 >= rowmin) Then
       PutImage(x1, y1, p^, XORPut);
    { If showshadow And Not fieldshadows[col+yshapetab[shape, orient, i, 2]]
      Then
       Begin
	PutImage(x1, rowmax+1, shadows^, XORPut);
	fieldshadows[col+yshapetab[shape, orient, i, 2]] := True
       End }
     End
   End; {-drawshape-}

  Procedure dispscore;
   Begin
    If oldscore <> score Then
     Begin
      SetColor(Black);
      Str(oldscore, buf);
      OutTextXY(522, 72, buf);
      SetColor(colorhigh);
      Str(score, buf);
      OutTextXY(522, 72, buf)
     End;
    If oldxvalue <> xvalue Then
     Begin
      SetColor(Black);
      Str(oldxvalue, buf);
      OutTextXY(522, 84, buf);
      SetColor(colorhigh);
      Str(xvalue, buf);
      OutTextXY(522, 84, buf)
     End;
    If (oldlevel <> level) Or (oldxshape <> xshape) Then
     Begin
      SetColor(Black);
      Str(oldlevel, buf);
      buf := buf+' '+xshapetitles[oldxshape];
      OutTextXY(522, 96, buf);
      SetColor(colorhigh);
      Str(level, buf);
      buf := buf+' '+xshapetitles[xshape];
      OutTextXY(522, 96, buf)
     End;
    If oldrowsclear <> rowsclear Then
     Begin
      SetColor(Black);
      Str(oldrowsclear, buf);
      OutTextXY(522, 108, buf);
      SetColor(colorhigh);
      Str(rowsclear, buf);
      OutTextXY(522, 108, buf)
     End
   End; {-dispscore-}

  Function chk : boolean;

   Var
    f		  : boolean;
    x, y, r	  : shortint;
    i		  : integer;

   Begin {-chk-}
    r := row+1;

    f := field[r, col];
    For i := 1 To xsize Do
     Begin
      y := r+yshapetab[shape, orient, i, 1];
      x := col+yshapetab[shape, orient, i, 2];
      If ((y >= 1) And (y <= depth+1)) And ((x >= 1) And (x <= blockcols))
      Then
       f := f Or field[y, x]
     End;

    chk := f
   End; {-chk-}

  Procedure chkmv(c : shortint);

   Var
    f1, f2	  : boolean;
    x, y	  : shortint;
    i		  : integer;
    xcol	  : shortint;

   Begin {-chkmv-}
    Inc(c, col);

    f1 := (c >= 1) And (c <= blockcols);
    If f1 Then
     f2 := field[row, c]
    Else
     f2 := True;
    For i := 1 To xsize Do
     Begin
      x  := c+yshapetab[shape, orient, i, 2];
      y  := row+yshapetab[shape, orient, i, 1];
      f1 := f1 And ((x >= 1) And (x <= blockcols));
      If f1 And ((y >= 1) And (y <= depth)) Then
       f2 := f2 Or field[y, x]
     End;

    If f1 And (Not f2) Then
     Begin
      xcol := col;
      col := c;
      drawshape;
      SetVisualPage(page);
      page := 1-page;
      SetActivePage(page);
      col := xcol;
      drawshape;
      col := c
     End
   End; {-chkmv-}

  Procedure chkrot(o : byte);

   Var
    f1, f2     : boolean;
    xorient    : byte;
    x, y       : shortint;
    i	       : integer;
    f	       : Text;

   Begin {-chkrot-}
    f1 := True;
    f2 := False;

    For i := 1 To xsize Do
     Begin
      y  := row+yshapetab[shape, o, i, 1];
      x  := col+yshapetab[shape, o, i, 2];
      f1 := f1 And ((x >= 1) And (x <= blockcols)) And
		   (y <= depth);
      If f1 And (y >= 1) Then
       f2 := f2 Or field[y, x]
     End;

    If f1 And (Not f2) Then
     Begin
      xorient := orient;
      orient := o;
      drawshape;
      SetVisualPage(page);
      page := 1-page;
      SetActivePage(page);
      orient := xorient;
      drawshape;
      orient := o
     End
   End; {-chkrot-}

  Procedure dropshape;

   Var
    oldrow, xrow  : byte;

   Begin {-dropshape-}
    oldrow := row;

    While Not chk Do
     Inc(row);
    drawshape;
    SetVisualPage(page);
    page := 1-page;
    SetActivePage(page);
    xrow := row;
    row := oldrow;
    drawshape;
    row := xrow;

    inc(score, level*oldrow+bonus);
  { Inc(score, level*(row-oldrow)+bonus); }
    dropped := True
   End; {-dropshape-}

  Procedure chkrows;

   Var
    f : boolean; i : integer;
    rows       : byte;
    r	       : byte;
    rinfo      : rinfotype;

   Function chkrow(r : byte) : boolean;

    Var
     f	       : boolean;
     i, j      : integer;

    Begin {-chkrow-}
     f := False;
     If r < depth+1 Then
      Begin
       f := field[r, 1];
       i := 2;
       While f And (i <= blockcols) Do
	Begin
	 f := f And field[r, i];
	 Inc(i)
	End;

       If f Then
	Begin
	 Inc(rowsclear);
	 If (level < maxlevel) And (rowsclear = advancetab[level]) Then
	  Begin
	   Inc(level);
	   tdelay := timedelaytab[level]
	  End;
	 Move(field[0, 1], field[1, 1], blockcols*r);
	 Inc(score, level*bonusrowclear+bonus)
	End
      End;
     chkrow := f
    End; {-chkrow-}

   Begin {-chkrows-}
    rows := 0;
    For r := row-2 To row+2 Do
     If chkrow(r) Then
      Begin
       Inc(rows);
       rinfo[rows] := r
      End;

    If rows > 0 Then
     Begin
      scrolldown(rows, rinfo);
      If rows > 1 Then
       Inc(score, level*((rows-1)*bonusmultclear)+bonus);
      f := false;
      I := 1;
      while (not f) and (i <= blockcols) do
       begin
	f := f or field[depth, i];
	inc(i);
       end;
      if not f then
       inc(score, level*bonusempty+bonus);
     End
   End; {-chkrows-}

  Procedure gameover;

   Var
    i, x, y, p	  : integer;
    f		  : boolean;

   Begin {-gameover-}
    f := True;
    For y := 1 To depth Do
     For p := 1 To 2 Do
      Begin
       For x := 1 To blockcols Do
	Begin
	 If Not field[y, x] Then
	   PutImage(colmin+(pixelsperblock*(x-1))+1,
		   rowmin+(pixelsperblock*(y-1)),
		   curtain[f]^, NormalPut);
	 f := Not f
	End;
       SetVisualPage(page);
       page := 1-page;
       SetActivePage(page);
       If Not KeyPressed Then
	Delay(dropdelay)
      End;

    setcolor(0);
    setfillstyle(solidfill, 0);
    bar(colmin+1, rowmin, colmax-1, rowmin+pixelsperblock);
    SetColor(colorhigh);
    SetTextStyle(DefaultFont, HorizDir, 1);
    SetTextJustify(CenterText, TopText);
    OutTextXY(320, rowmin+4, 'Game Over');

    i := 1;
    Repeat
     SetVisualPage(page);
     page := 1-page;
     SetActivePage(page);
     Delay(i*dropdelay);
     Inc(i)
    Until (i > 25) Or (Not Odd(i) And KeyPressed);

    While KeyPressed Do
     ch := getkey
   End; {-gameover-}

  Begin {-play-}
   initlevel := level;
   endgame   := False;
   nextshape := Random(shapemap)+1;
   nextcolor := Random(ncolors)+1;
   nextstyle := Random(nstyles)+1;
   xvalue    := 0;
   tdelay    := timedelaytab[level];

   oldscore	:= 255;
   oldlevel	:= 255;
   oldxvalue	:= 0;
   oldxshape	:= (xshape+1) Mod xshapelevels;
   oldrowsclear := 65535;

 { dispscore;
   SetVisualPage(page);
   page := 1-page;
   SetActivePage(page);
   dispscore;
   oldscore	:= 0;
   oldlevel	:= level;
   oldxvalue	:= xvalue;
   oldxshape	:= xshape;
   oldrowsclear := 0; }

   If shownext Then
    putshape(111, 54, nextshape, styletab[nextcolor, nextstyle]);
   SetVisualPage(page);
   page := 1-page;
   SetActivePage(page);
   If shownext Then
    putshape(111, 54, nextshape, styletab[nextcolor, nextstyle]);

   Repeat
    Inc(score, xvalue);
    shape   := nextshape;
    orient  := 0;
    row     := initrow;
    col     := initcol;
    color   := nextcolor;
    style   := nextstyle;
    dropped := False;
    xsize   := shapetab[shape, info, 1];
    xvalue  := level*shapetab[shape, info, 2]+bonus;
    nextshape := Random(shapemap)+1;
    nextcolor := Random(ncolors)+1;
    nextstyle := Random(nstyles)+1;

    drawshape;
    dispscore;
    If shownext Then
     Begin
      putshape(111, 54, shape, styletab[color, style]);
      putshape(111, 54, nextshape, styletab[nextcolor, nextstyle])
     End;
    SetVisualPage(page);
    page := 1-page;
    SetActivePage(page);
    dispscore;
    If shownext Then
     Begin
      putshape(111, 54, shape, styletab[color, style]);
      putshape(111, 54, nextshape, styletab[nextcolor, nextstyle])
     End;
    oldscore	 := score;
    oldxvalue	 := xvalue;
    oldlevel	 := level;
    oldxshape	 := xshape;
    oldrowsclear := rowsclear;

    t := gettimer+tdelay;
    Repeat Until (gettimer > t);
    While KeyPressed Do
     ch := getkey;

    If chk Then
     endgame := True
    Else
     Begin
      Repeat
       Inc(row);
       drawshape;
       SetVisualPage(page);
       page := 1-page;
       SetActivePage(page);
       Dec(row);
       drawshape;
       Inc(row);

       t := gettimer+tdelay;
       Repeat
	Repeat Until KeyPressed Or (gettimer > t);
	If KeyPressed Then
	 Begin
	  ch := getkey;
	  if lo(ch) < 29 then
	   case hi(ch) of
 { Esc }	 1: begin
	   { 1, 68: Begin
		     if hi(ch) = 68 then
		      fake; }
		     Repeat Until KeyPressed;
		     ch := getkey;
		     If chr(lo(ch)) = #27 Then
		      Begin
		       dropshape;
		       endgame := True
		      End
		    End;
 { ^W }       { 17: Begin
		     showshadow := Not showshadow;
		     drawshape;
		     SetVisualPage(page);
		     page := 1-page;
		     SetActivePage(page);
		     showshadow := Not showshadow;
		     drawshape;
		     showshadow := Not showshadow;
		     If showshadow Then
		      Dec(bonus, bonusshadow)
		     Else
		      Inc(bonus, bonusshadow);
		     While KeyPressed Do
		      ch := getkey
		    End; }
 { ^S } 	31: tones := not tones;
 { ^L }     38, 47: Begin
		     level := (level Mod maxlevel)+1;
		     tdelay := timedelaytab[level];
		     drawshape;
		     dispscore;
		     SetVisualPage(page);
		     page := 1-page;
		     SetActivePage(page);
		     drawshape;
		     dispscore;
		     oldlevel := level;
		     While KeyPressed Do
		      ch := getKey
		    End;
 { ^\ } 	43: begin
		     cleanup;
		     halt
		    end;
 { ^X } 	45: Begin
		     xshape := (xshape Mod xshapelevels)+1;
		     Case xshape Of
		      1: shapemap := xshapeclassic;
		      2: shapemap := xshapeeasy;
		      3: shapemap := xshapemedium;
		      4: shapemap := xshapehard
		     End;
		     drawshape;
		     dispscore;
		     SetVisualPage(page);
		     page := 1-page;
		     SetActivePage(page);
		     drawshape;
		     dispscore;
		     oldxshape := xshape;
		     While KeyPressed Do
		      ch := getkey
		    End;
 { ^B } 	48: Begin
		     i := styleblocks;
		     If shownext Then
		      putshape(111, 54, nextshape,
			       styletab[nextcolor, nextstyle]);
		     styleblocks := (styleblocks Mod nstyletabs)+1;
		     Move(xstyletabs[styleblocks], styletab,
			  SizeOf(styletab));
		     drawshape;
		     If shownext Then
		      putshape(111, 54, nextshape,
			       styletab[nextcolor, nextstyle]);
		     SetVisualPage(page);
		     page := 1-page;
		     SetActivePage(page);
		     Move(xstyletabs[i], styletab,
			  SizeOf(styletab));
		     drawshape;
		     If shownext Then
		      putshape(111, 54, nextshape,
			       styletab[nextcolor, nextstyle]);
		     Move(xstyletabs[styleblocks], styletab,
			  SizeOf(styletab));
		     If shownext Then
		      putshape(111, 54, nextshape,
			       styletab[nextcolor, nextstyle]);
		     While KeyPressed Do
		      ch := getkey
		    End;
 { ^G }       { 34: begin
		     showguide := not showguide;
		     if showguide then
		      begin
		       dec(bonus, bonusguide);
		       drawshape;
		       drawguide(colornormal);
		       SetVisualPage(page);
		       page := 1-page;
		       SetActivePage(page);
		       drawshape;
		       drawguide(colornormal);
		      end
		     else begin
		      inc(bonus, bonusguide);
		      drawshape;
		      drawguide(0);
		      SetVisualPage(page);
		      page := 1-page;
		      SetActivePage(page);
		      drawshape;
		      drawguide(0);
		     end;
		    end; }
 { ^N } 	49: Begin
		     shownext := Not shownext;
		     If shownext Then
		      Dec(bonus, bonusnext)
		     Else
		      Inc(bonus, bonusnext);
		     putshape(111, 54, nextshape,
			      styletab[nextcolor, nextstyle]);
		     drawshape;
		     SetVisualPage(page);
		     page := 1-page;
		     SetActivePage(page);
		     putshape(111, 54, nextshape,
			      styletab[nextcolor, nextstyle]);
		     drawshape;
		     While KeyPressed Do
		      ch := getkey
		    End
	   end
	  else
	   begin
	    k := 1;
	    while (hi(ch) <> keybinding[k]) and (k <= nkeys) do
	     inc(k);
	    if k <= nkeys then
	     case k of
		     keydrop: dropshape;
		     keyleft: chkmv(left);
		    keyright: chkmv(right);
	      keyrotateright: chkrot((orient+1) Mod (norients+1));
	       keyrotateleft: chkrot((norients+orient) Mod (norients+1))
	     end
	    end;
	 end;
       Until dropped Or (gettimer > t);
      Until dropped Or chk;

      drawshape;

      field[row, col] := True;
      For i := 1 To xsize Do
       field[row+yshapetab[shape, orient, i, 1],
	     col+yshapetab[shape, orient, i, 2]] := True;

      chkrows;

      t := gettimer+(tdelay Shr 1);
      Repeat Until (gettimer > t);
      While KeyPressed Do
       ch := getkey
     End;
   Until endgame;

   dispscore;
   SetVisualPage(page);
   page := 1-page;
   SetActivePage(page);
   dispscore;
   oldscore	:= score;
   oldxvalue	:= xvalue;
   oldlevel	:= level;
   oldxshape	:= xshape;
   oldrowsclear := rowsclear;

   While KeyPressed Do
    ch := getkey;
   gameover;

   Repeat Until KeyPressed;
   While KeyPressed Do
    ch := getkey
  End;

 Procedure postgame;

  Var
   ch		  : word;
   today	  : DateTime;
   i, j 	  : word;
   rank, x, s	  : integer;

  Begin
   rank := 0;

   If rowsclear > 0 Then
    Begin
     i	  := 1;
     While (i <= nhiscores) And (hiscore[i].score >= score) Do
      Inc(i);
     If i <= nhiscores Then
      Begin
       rank := i;
       For j := nhiscores-1 DownTo i Do
	hiscore[j+1] := hiscore[j];
       hiscore[i].score     := score;
       hiscore[i].level     := level;
       hiscore[i].rowsclear := rowsclear;

       GetTime(today.hour, today.min, today.sec, j);
       GetDate(today.year, today.month, today.day, j);
       Dec(today.year, 1900);
       Str(today.month:2, hiscore[i].date);
       Str(today.day:2, buf);
       hiscore[i].date := hiscore[i].date+'/'+buf;
       Str(today.year:2, buf);
       hiscore[i].date := hiscore[i].date+'/'+buf;
       fillzero(hiscore[i].date);
       Str(today.hour:2, hiscore[i].time);
       Str(today.min:2, buf);
       hiscore[i].time := hiscore[i].time+':'+buf;
       Str(today.sec:2, buf);
       hiscore[i].time := hiscore[i].time+':'+buf;
       fillzero(hiscore[i].time);
       hiscore[i].version := version;

       ClearDevice;

       SetTextJustify(CenterText, TopText);
       SetTextStyle(SansSerifFont, HorizDir, 4);
       SetColor(colorhigh);
       OutTextXY(320, 5, 'Congratulations!');

       SetTextStyle(DefaultFont, HorizDir, 1);
       SetColor(colornormal);
       OutTextXY(320, 46, 'You''ve made it into the Glorious Fifteen;');
       OutTextXY(320, 58, 'please enter your name for posterity:');

       SetColor(colornormal);
       placewindow(214, 155, 426, 195);

       SetVisualPage(page);
       page := 1-page;

       SetTextStyle(SmallFont, HorizDir, 4);
       x := 1;
       Repeat
	SetColor(colorhigh);
	OutTextXY(224+6*(x-1), 171, '_');
	Repeat Until KeyPressed;
	ch := getkey;
	Case lo(ch) Of
	   0: While KeyPressed Do
	       ch := getkey;
	   8: If x > 1 Then
	       Begin
		SetColor(Black);
		OutTextXY(224+6*(x-1), 171, '_');
		Dec(x);
		OutTextXY(224+6*(x-1), 171, hiscore[i].name[x])
	       End;
	  13: hiscore[i].name[0] := Chr(x-1);
	  27: If x > 1 Then
	       Begin
		SetColor(Black);
		OutTextXY(224+6*(x-1), 171, '_');
		For s := x DownTo 1 Do
		 OutTextXY(224+6*(s-1), 171, hiscore[i].name[s]);
		x := 1
	       End;
	 Else If x < SizeOf(bufstr) Then
	       Begin
		SetColor(Black);
		OutTextXY(224+6*(x-1), 171, '_');
		SetColor(colorhigh);
		OutTextXY(224+6*(x-1), 171, chr(lo(ch)));
		hiscore[i].name[x] := chr(lo(ch));
		Inc(x)
	       End
	End
       Until (lo(ch) = 13) or (x > SizeOf(bufstr))
      End
    End;

   SetActivePage(page);
   ClearDevice;

   SetTextStyle(SansSerifFont, HorizDir, 4);
   SetTextJustify(CenterText, TopText);
   SetColor(colorhigh);
   OutTextXY(320, 5, 'The Glorious Fifteen');

   SetColor(colornormal);
   SetFillStyle(SolidFill, colornormal);
   placewindow(16, 50, 615, 256);

   SetTextStyle(DefaultFont, HorizDir, 1);
   SetTextJustify(LeftText, TopText);
   SetColor(colorhigh);
   OutTextXY(24, 60, 'Rank  Score  Level Rows   Date     Time   Name');

   SetColor(colornormal);
   SetTextStyle(SmallFont, HorizDir, 4);
   For i := 1 To nhiscores Do
    Begin
     If rank = i Then
      SetColor(colorhigh);
     SetTextJustify(CenterText, TopText);
     Str(i:2, buf);
     OutTextXY(40, 72+12*(i-1), buf);
     If hiscore[i].score <> 0 Then
      Begin
       Str(hiscore[i].score:7, buf);
       OutTextXY(92, 72+12*(i-1), buf);
       Str(hiscore[i].level:2, buf);
       OutTextXY(148, 72+12*(i-1), buf);
       Str(hiscore[i].rowsclear:4, buf);
       OutTextXY(192, 72+12*(i-1), buf);
       OutTextXY(248, 72+12*(i-1), hiscore[i].date);
       OutTextXY(320, 72+12*(i-1), hiscore[i].time);
       SetTextJustify(LeftText, TopText);
       OutTextXY(360, 72+12*(i-1), hiscore[i].name);
       OutTextXY(563, 72+12*(i-1), hiscore[i].version)
      End;
     If rank = i Then
      SetColor(colornormal)
    End;

   SetTextStyle(DefaultFont, HorizDir, 1);
   SetTextJustify(CenterText, TopText);
   SetColor(colornormal);
   OutTextXY(320, 300, 'Press Y to try again or N to exit.');

   SetVisualPage(page);
   page := 1-page;
   SetActivePage(page);
   ClearDevice;

   Repeat
    Repeat Until KeyPressed;
    ch := getkey;
   Until (hi(ch) In [21, 49]);

   endrun := hi(ch) = 49
  End;

{ 12345678901234567890123456789012345678901234567890123456789012345678901234
  rank	score  level rows   date     time   name'
   00  0000000	 00  0000 00/00/00 00:00:00 12345678901234567890123456789012
}

 Procedure cleanup;

  Var
   i		  : integer;

  Procedure configflag(f : boolean);
   Begin
    If f Then
     WriteLn(fconfig, 'Yes')
    Else
     WriteLn(fconfig, 'No')
   End; {-configflag-}

  Begin {-cleanup-}
   dotext;

   Assign(fhiscore, hiscorename);
   filemode := 2;
   Rewrite(fhiscore);
   if ioresult = 0 then
    begin
     i := 1;
     While (i <= nhiscores) And (hiscore[i].score > 0) Do
      Begin
       Write(fhiscore, hiscore[i]);
       Inc(i)
      End;
     Close(fhiscore)
    end;

   Assign(fconfig, configname);
   filemode := 2;
   Rewrite(fconfig);
   if ioresult = 0 then
    begin
     WriteLn(fconfig, '# ', id, '':1, version, ' configuration file');
   { WriteLn(fconfig, '# ', copyright); }
     Write(fconfig, 'display=');
     Case display Of
      bw    : writeln(fconfig, 'BW');
      color : WriteLn(fconfig, 'Color');
      mono  : WriteLn(fconfig, 'Mono');
      plasma: WriteLn(fconfig, 'Plasma')
     End;
     writeln(fconfig, 'depth=', depth);
     WriteLn(fconfig, 'height=', height);
     WriteLn(fconfig, 'level=', initlevel);
     Write(fconfig, 'shownext=');
     configflag(shownext);
     write(fconfig, 'showguide=');
     configflag(showguide);
   { Write(fconfig, 'showshadow=');
     configflag(showshadow); }
     Write(fconfig, 'sound=');
     configflag(tones);
     WriteLn(fconfig, 'styleblocks=', styleblocktitles[styleblocks]);
     Write(fconfig, 'title=');
     configflag(title);
     Write(fconfig, 'tournament=');
     configflag(tournament);
     WriteLn(fconfig, 'tournamentgame=', tournamentgame);
     WriteLn(fconfig, 'xshape=', xshapetitles[xshape]);

     write(fconfig, 'palette=');
     for i := 0 to palettesiz-2 do
      write(fconfig, userpalette.colors[i], ',');
     writeln(fconfig, userpalette.colors[palettesiz-1]);

     write(fconfig, 'keybinding=');
     if binding <> nkeybindings then
      writeln(fconfig, keybindingtitles[binding])
     else
      begin
       for i := 1 to nkeys-1 do
	write(fconfig, keybinding[i], ',');
       writeln(fconfig, keybinding[nkeys]);
      end;

     Close(fconfig)
    end;
   numlock(false)
  End; {-cleanup-}

 Begin
  init;
  drawtitle;
  Repeat
   initgame;
   If Not endrun Then
    Begin
     drawscreen;
     play;
     postgame
    End;
  Until endrun;
  cleanup
 End.

