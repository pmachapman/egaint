(*
 * Copyright 1990 Eric Ng
 *
 * This program is free software; you can redistribute it and(*or modify
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

{ this was a quick and dirty hack which I threw together in order to
  determine the default palette values for egaint 0.93.07; this means that
  this was written almost one full year ago, so I make no apologies for
  the condition of this code -eric }

program x;
 uses crt, dos, graph, driver;
 const
  filltab : array[1..4] of fillpatterntype =
      (($ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff),
       ($aa, $55, $aa, $55, $aa, $55, $aa, $55),
       ($99, $cc, $66, $33, $99, $cc, $66, $33),
       ($99, $33, $66, $cc, $99, $33, $66, $cc));
 var gd:integer;
  gm:integer; buf:string[32];
 var i,j,k,l,m,n,o,p:integer;
     c,a,b:char;
     col:array[1..15] of shortint;
 begin
   col[1] := 7;
   col[2] := 63;
   col[3] := 47;
   col[4] := 49;
   col[5] := 25;
   col[6] := 27;
   col[7] := 10;
   col[8] := 50;
   col[9] := 44;
   col[10] := 37;
   col[11] := 39;
   col[12] := 36;
   col[13] := 38;
   col[14] := 55;
   col[15] := 62;
  if registerbgidriver(@EGAVGADriver) < 0 then
   halt(0);
  gd:=ega; gm:=egahi;
  initgraph(gd, gm, '');
    settextjustify(centertext, toptext);
     settextstyle(smallfont, horizdir, 4);
  setcolor(2);
  for i:=1 to 15 do
   begin
    setpalette(i, col[i]);
    outtextxy((i-1)*42+20, 330, chr(i+ord('a')-1)+chr(i+ord('A')-1));
   for j:=1 to 4 do
    begin
     setfillpattern(filltab[j], i);
     bar((i-1)*42, (j-1)*77, i*42-5, j*77-7);
    end;
    end;
  repeat
   for i := 1 to 15 do
    begin
     setcolor(2);
     str(col[i]:2,buf);
     outtextxy((i-1)*42+20, 340, buf);
    end;
  repeat until keypressed;
  a:=readkey;
  if a in ['A'..'O'] then
   begin
    k:=ord(a)-ord('A')+1;
    str(col[k]:2,buf);
    setcolor(0);
    outtextxy((k-1)*42+20, 340, buf);

    col[k]:=col[k]+1;
    if col[k]>63 then col[k]:=0;
    setpalette(k, col[k]);

    str(col[k]:2,buf);
    setcolor(2);
    outtextxy((k-1)*42+20, 340, buf);

   end;
  if a in ['a'..'o'] then
   begin
    k:=ord(a)-ord('a')+1;
    str(col[k]:2,buf);
    setcolor(0);
    outtextxy((k-1)*42+20, 340, buf);
    col[k]:=col[k]-1;
    if col[k]<0 then col[k]:=63;
    setpalette(k, col[k]);
    str(col[k]:2,buf);
    setcolor(2);
    outtextxy((k-1)*42+20, 340, buf);
   end;
  until a = #27;
 textmode(c80);
 write('palette=0,');
 for i := 1 to 14 do
  write(col[i], ',');
 writeln(col[15]);
end.
