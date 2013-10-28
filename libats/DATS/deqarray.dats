(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2013 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by the
** Free Software Foundation; either version 2.1, or (at your option)  any
** later version.
**
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
**
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)

(* ****** ****** *)

(* Author: Hongwei Xi *)
(* Authoremail: hwxi AT cs DOT bu DOT edu *)
(* Start time: September, 2013 *)

(* ****** ****** *)
  
#define ATS_PACKNAME "ATSLIB.libats.deqarray"
#define ATS_DYNLOADFLAG 0 // no need for dynloading at run-time
#define ATS_EXTERN_PREFIX "atslib_" // prefix for external names
  
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/deqarray.sats"

(* ****** ****** *)

implement
{a}(*tmp*)
deqarray_make_cap
  (cap) = deq where
{
//
val A = arrayptr_make_uninitized<a> (cap)
//
val (pfat, pfgc | p) = ptr_alloc<deqarray_tsize> ()
//
val (pfngc | deq) = deqarray_make_ngc (pfat | p, A, cap, sizeof<a>)
//
prval ((*void*)) = mfree_gcngc_v_nullify (pfgc, pfngc)
//
} // end of [deqarray_make_cap]

(* ****** ****** *)

local
//
extern
fun deqarray_get_size__tsz{a:vt0p}
  {m,n:int} (deq: !deqarray (a, m, n), sizeof_t(a)):<> size_t(n) = "mac#%"
extern
fun deqarray_get_capacity__tsz{a:vt0p}
  {m,n:int} (deq: !deqarray (a, m, n), sizeof_t(a)):<> size_t(m) = "mac#%"
//
in (* in of [local] *)

implement{a}
deqarray_get_size (deq) = deqarray_get_size__tsz (deq, sizeof<a>)
implement{a}
deqarray_get_capacity (deq) = deqarray_get_capacity__tsz (deq, sizeof<a>)

end // end of [local]

(* ****** ****** *)

implement{a}
fprint_deqarray_sep
  (out, deq, sep) = let
//
implement{}
fprint_deqarray$sep (out) = fprint_string (out, sep)
//
in
  fprint_deqarray<a> (out, deq)
end // end of [fprint_deqarray_sep]

(* ****** ****** *)

implement
{a}{env}
deqarray_foreach$cont (x, env) = true

implement{a}
deqarray_foreach (deq) = let
  var env: void = () in deqarray_foreach_env<a><void> (deq, env)
end // end of [deqarray_foreach]

(* ****** ****** *)

(* end of [deqarray.dats] *)
