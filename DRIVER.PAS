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

Unit Driver;
 Interface
  Procedure EgaVgaDriver;
  Procedure HercDriver;
 Implementation
  Procedure EgaVgaDriver; External;
{$l egavga.obj}
  Procedure HercDriver; External;
{$l herc.obj}
End.
