(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2012 Hongwei Xi, ATS Trustful Software, Inc.
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
(* Start time: Feburary, 2013 *)

(* ****** ****** *)
//
// HX-2013-02: this is a completely new effort
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"
// end of [staload]

(* ****** ****** *)

staload "libats/SATS/dllist.sats"

(* ****** ****** *)

#define nullp the_null_ptr

(* ****** ****** *)

staload "libats/SATS/gnode.sats"

(* ****** ****** *)

stadef mytkind = $extkind"atslib_dllist"

(* ****** ****** *)

typedef mynode0 (a:vt0p) = gnode0 (mytkind, a)
typedef mynode1 (a:vt0p) = gnode1 (mytkind, a)

(* ****** ****** *)
//
extern
fun{a:vt0p}
mynode_make_elt (x: a):<!wrt> mynode1 (a)
//
extern
fun{a:t0p} // [a] is nonlinear
mynode_free (nx: mynode1 (INV(a))):<!wrt> void
extern
fun{a:vt0p}
mynode_free_elt
  (nx: mynode1 (INV(a)), res: &(a?) >> a):<!wrt> void
//
extern
fun{a:vt0p}
mynode_getfree_elt (nx: mynode1 (INV(a))):<!wrt> (a)
//
(* ****** ****** *)

assume
dllist_vtype (
  a:vt0p, f:int(*front*), r:int(*rear*)
) = mynode0 (a) // end of [dllist_vtype]

(* ****** ****** *)

implement{}
dllist_nil () = gnode_null ()

(* ****** ****** *)

implement{a}
dllist_sing (x) = let
in
  dllist_cons<a> (x, dllist_nil ())
end // end of [dllist_sing]

(* ****** ****** *)

implement{a}
dllist_cons
  (x, xs) = nx where {
  val nx = mynode_make_elt<a> (x)
  val () = gnode_set_prev_null (nx)
  val () = gnode_link10 (nx, xs)
} // end of [dllist_cons]

implement{a}
dllist_uncons
  (xs) = let
  val nx = $UN.cast{mynode1(a)}(xs)
  val nx2 = gnode_get_next (nx)
  val () = gnode0_set_prev_null (nx2)
  val () = xs := nx2
in
  mynode_getfree_elt (nx)
end // end of [dllist_uncons]

(* ****** ****** *)

implement{a}
dllist_snoc
  (xs, x) = nx where {
  val nx = mynode_make_elt<a> (x)
  val () = gnode_set_next_null (nx)
  val () = gnode_link01 (xs, nx)
} // end of [dllist_snoc]

(* ****** ****** *)

implement{a}
dllist_make_list
  (xs) = let
//
fun loop (
  nx0: mynode1 (a), xs: List (a)
) : void = let
in
//
case+ xs of
| list_cons
    (x, xs) => let
    val nx1 =
      mynode_make_elt<a> (x)
    // end of [val]
    val () = gnode_link11 (nx0, nx1)
  in
    loop (nx1, xs)
  end // end of [loop]
| list_nil () => let
    val () = gnode_set_next_null (nx0)
  in
    // nothing
  end // end of [list_nil]
//
end // end of [loop]
//
in
//
case+ xs of
| list_cons
    (x, xs) => let
    val nx0 = mynode_make_elt<a> (x)
    val () = $effmask_all (loop (nx0, xs))
  in
    nx0 (*first-node*)
  end // end of [list_cons]
| list_nil () => dllist_nil ()
//
end // end of [dllist_make_list]

(* ****** ****** *)

implement{}
dllist_is_nil
  {a}{f,r} (xs) =
  $UN.cast{bool(r==0)}(gnodelst_is_nil (xs))
// end of [dllist_is_nil]

implement{}
dllist_is_cons
  {a}{f,r} (xs) =
  $UN.cast{bool(r > 0)}(gnodelst_is_cons (xs))
// end of [dllist_is_cons]

(* ****** ****** *)

implement{a}
dllist_is_atbeg
  {f,r} (xs) = let
//
val nxs = xs
val iscons = gnodelst_is_cons (nxs)
//
val ans = (
  if iscons then
    gnode_is_null (gnode_get_prev (nxs))
  else true // end of [if]
) : bool // end of [val]
//
in
  $UN.cast{bool(f==0)}(ans)
end // end of [dllist_is_atbeg]

(* ****** ****** *)

implement{a}
dllist_is_atend
  {f,r} (xs) = let
//
val nxs = $UN.cast{mynode1(a)}(xs)
//
in
  $UN.cast
    {bool(r==1)} (
    gnode_is_null (gnode_get_next (nxs))
  )
end // end of [dllist_is_atend]

(* ****** ****** *)

implement{a}
rdllist_is_atbeg
  {f,r} (xs) = dllist_is_atend {f,r} (xs)
// end of [rdllist_is_atbeg]

implement{a}
rdllist_is_atend
  {f,r} (xs) = dllist_is_atbeg {f,r} (xs)
// end of [rdllist_is_atend]

(* ****** ****** *)

implement{a}
dllist_getref_elt (xs) = let
  val nxs = $UN.cast{mynode1(a)}(xs) in gnode_getref_elt (nxs)
end // end of [dllist_getref_elt]

implement{a}
dllist_getref_next (xs) = let
  val nxs = $UN.cast{mynode1(a)}(xs) in gnode_getref_next (nxs)
end // end of [dllist_getref_next]

implement{a}
dllist_getref_prev (xs) = let
  val nxs = $UN.cast{mynode1(a)}(xs) in gnode_getref_prev (nxs)
end // end of [dllist_getref_prev]

(* ****** ****** *)

implement{a}
dllist_get
  {f,r} (xs) = let
  val p_elt =
    dllist_getref_elt {f,r} (xs) in $UN.ptr_get<a> (p_elt)
  // end of [val]
end // end of [dllist_get]

implement{a}
dllist_set
  {f,r} (xs, x) = let
  val p_elt =
    dllist_getref_elt {f,r} (xs) in $UN.ptr_set<a> (p_elt, x)
  // end of [val]
end // end of [dllist_set]

(* ****** ****** *)

(*
fun{a:vt0p}
dllist_length
  {f,r:int} (xs: !dllist (INV(a), f, r)):<> int (r)
*)
implement{a}
dllist_length
  {f,r} (xs) = let
  val nxs = $UN.cast{mynode0(a)}(xs)
in
  $UN.cast{int(r)}(gnodelst_length (nxs))
end // end of [dllist_length]

(*
fun{a:vt0p}
rdllist_length
  {f,r:int} (xs: !dllist (INV(a), f, r)):<> int (f)
*)
implement{a}
rdllist_length
  {f,r} (xs) = let
  val nxs = $UN.cast{mynode1(a)}(xs)
in
  $UN.cast{int(f)}(gnodelst_rlength (nxs))
end // end of [rdllist_length]

(* ****** ****** *)

(*
fun{a:vt0p}
dllist_move
  {f,r:int | r > 1}
  (xs: dllist (INV(a), f, r)):<> dllist (a, f+1, r-1)
*)
implement{a}
dllist_move (xs) = let
  val nx = $UN.cast{mynode1(a)}(xs) in gnode_get_next (nx)
end // end of [dllist_move]

(*
fun{a:vt0p}
dllist_move_all
  {f,r:int | r > 0}
  (xs: dllist (INV(a), f, r)):<> dllist (a, f+r-1, 1)
*)
implement{a}
dllist_move_all
  {f,r} (xs) = let
//
fun loop (
  nxs: mynode1 (a)
) : mynode1 (a) = let
  val nxs_next = gnode_get_next (nxs)
in
  if gnodelst_is_cons (nxs_next) then loop (nxs_next) else nxs
end // end of [loop]
//
val nxs = $UN.cast{mynode1(a)}(xs)
//
in
  $effmask_all (loop (nxs))
end // end of [dllist_move_all]

(* ****** ****** *)

(*
fun{a:vt0p}
rdllist_move
  {f,r:int | f > 0}
  (xs: dllist (INV(a), f, r)):<> dllist (a, f-1, r+1)
*)
implement{a}
rdllist_move (xs) = let
  val nx = $UN.cast{mynode1(a)}(xs) in gnode_get_prev (nx)
end // end of [rdllist_move]

(*
fun{a:vt0p}
rdllist_move_all
  {f,r:int | r >= 0}
  (xs: dllist (INV(a), f, r)):<> dllist (a, 0(*front*), f+r)
*)
implement{a}
rdllist_move_all
  {f,r} (xs) = let
//
fun loop (
  nxs: mynode1 (a)
) : mynode1 (a) = let
  val nxs_prev = gnode_get_prev (nxs)
in
  if gnodelst_is_cons (nxs_prev) then loop (nxs_prev) else nxs
end // end of [loop]
//
val nxs = xs
//
in
  if gnodelst_is_cons (nxs) then $effmask_all (loop (nxs)) else nxs
end // end of [rdllist_move_all]

(* ****** ****** *)

(*
fun{a:vt0p}
dllist_insert_next
  {f,r:int | r > 0}
  (xs: dllist (INV(a), f, r), x0: a):<!wrt> dllist (a, f, r+1)
*)
implement{a}
dllist_insert_next
  (xs, x0) = nx where {
  val nx = $UN.cast{mynode1(a)}(xs)
  val nx2 = mynode_make_elt<a> (x0)
  val () = gnode_insert_next (nx, nx2)
} // end of [dllist_insert_next]

(*
fun{a:vt0p}
dllist_insert_prev
  {f,r:int | r > 0}
  (xs: dllist (INV(a), f, r), x0: a):<!wrt> dllist (a, f, r+1)
*)
implement{a}
dllist_insert_prev
  (xs, x0) = nx2 where {
  val nx = $UN.cast{mynode1(a)}(xs)
  val nx2 = mynode_make_elt<a> (x0)
  val () = gnode_insert_prev (nx, nx2)
} // end of [dllist_insert_prev]

(* ****** ****** *)

(*
fun{a:vt0p}
dllist_remove
  {f,r:int | r > 1}
  (xs: &dllist (INV(a), f, r) >> dllist (a, f, r-1)):<!wrt> (a)
*)
implement{a}
dllist_remove
  (xs) = let
  val nx = $UN.cast{mynode1(a)}(xs)
  val nx_prev = gnode_get_prev (nx)
  val nx_next = gnode_get_next (nx)
  val nx_next = $UN.cast{mynode1(a)}(nx_next)
  val () = gnode_link01 (nx_prev, nx_next)
  val () = (xs := nx_next)
in
  mynode_getfree_elt (nx)
end // end of [dllist_remove]

(* ****** ****** *)

implement{a}
dllist_append
  (xs1, xs2) = let
//
val nxs1 = xs1 and nxs2 = xs2
//
fun loop (
  nxs1: mynode1 (a), nxs2: mynode0 (a)
) : void = let
  val nxs1_next = gnode_get_next (nxs1)
  val iscons = gnodelst_is_cons (nxs1_next)
in
//
if iscons then loop (nxs1_next, nxs2) else gnode_link10 (nxs1, nxs2)
//
end // end of [loop]
//
val iscons = gnodelst_is_cons (nxs1)
//
in
//
if iscons then let
  val () = $effmask_all (loop (nxs1, nxs2)) in nxs1
end else nxs2 // end of [if]
//
end // end of [dllist_append]

(* ****** ****** *)

implement{a}
dllist_reverse (xs) = let
//
fun loop (
  nxs: mynode0 (a), res: mynode1 (a)
) : mynode1 (a) = let
  val iscons = gnodelst_is_cons (nxs)
in
//
if iscons then let
  val nx = nxs
  val nxs = gnode_get_next (nx)
  val () = gnode_link11 (nx, res)
in
  loop (nxs, nx)
end else res // end of [if]
//
end // end of [loop]
//
val nxs = xs
val iscons = gnodelst_is_cons (nxs)
//
in
//
if iscons then let
  val nx = nxs
  val nxs = gnode_get_next (nx)
  val nxp = gnode_get_prev (nx)
  val () = gnode_set_next_null (nx)
  val res = $effmask_all (loop (nxs, nx))
  val () = gnode_link01 (nxp, res)
in
  res
end else
  nxs
// end of [if]
//
end // end of [dllist_reverse]

(* ****** ****** *)

implement{a}
dllist_free (xs) = let
//
val nxs = xs
//
fun loop (
  nxs: mynode0 (a)
) : void = let
//
val iscons = gnodelst_is_cons (nxs)
//
in
//
if iscons then let
  val nxs2 = gnode_get_next (nxs)
  val () = mynode_free (nxs)
in
  loop (nxs2)
end else () // end of [if]
//
end // end of [loop]
//
in
  $effmask_all (loop (nxs))
end // end of [dllist_free]

(* ****** ****** *)

implement{}
fprint_dllist$sep
  (out) = fprint_string (out, "->")
implement{a}
fprint_dllist (out, xs) = let
//
val nxs = xs
//
fun loop (
  out: FILEref, nxs: mynode0 (a), i: int
) : void = let
  val iscons = gnodelst_is_cons (nxs)
in
//
if iscons then let
  val nx0 = nxs
  val nxs = gnode_get_next (nx0)
  val () =
    if i > 0 then fprint_dllist$sep (out)
  // end of [val]
  val [l:addr] p_elt = gnode_getref_elt (nx0)
  prval (pf, fpf) = $UN.ptr_vtake {a}{l} (p_elt)
  val () = fprint_ref (out, !p_elt)
  prval () = fpf (pf)
in
  loop (out, nxs, i+1)
end // end of [if]
//
end // end of [loop]
//
in
  loop (out, nxs, 0)
end // end of [fprint_dllist]

(* ****** ****** *)

implement{}
fprint_rdllist$sep
  (out) = fprint_string (out, "<-")
implement{a}
fprint_rdllist (out, xs) = let
//
val nxs = xs
//
fun loop (
  out: FILEref, nxs: mynode0 (a), i: int
) : void = let
  val iscons = gnodelst_is_cons (nxs)
in
//
if iscons then let
  val nx0 = nxs
  val nxs = gnode_get_prev (nx0)
  val () =
    if i > 0 then fprint_rdllist$sep (out)
  // end of [val]
  val [l:addr] p_elt = gnode_getref_elt (nx0)
  prval (pf, fpf) = $UN.ptr_vtake {a}{l} (p_elt)
  val () = fprint_ref (out, !p_elt)
  prval () = fpf (pf)
in
  loop (out, nxs, i+1)
end // end of [if]
//
end // end of [loop]
//
val iscons = gnodelst_is_cons (nxs)
//
in
  if iscons then loop (out, gnode_get_prev (nxs), 0) else ()
end // end of [fprint_rdllist]

(* ****** ****** *)

datavtype
dlnode_vtype (a:vt@ype+) =
  | DLNODE of (a, ptr(*next*), ptr(*prev*))
vtypedef dlnode (a:vt0p) = dlnode_vtype (a)

(* ****** ****** *)

extern
praxi dlnode_vfree {a:vt0p} (nx: dlnode (a)): void
extern
castfn
mynode_decode {a:vt0p} (nx: mynode1 (INV(a))):<> dlnode (a)
extern
castfn
mynode_encode {a:vt0p} (nx: dlnode (INV(a))):<> mynode1 (a)

(* ****** ****** *)

implement{a}
mynode_make_elt
  (x) = let
in
  $UN.castvwtp0{mynode1(a)}(DLNODE{a}(x, _, _))
end // end of [mynode_make_elt]

implement{a}
mynode_free (nx) = let
  val nx = mynode_decode (nx)
  val~DLNODE (_, _, _) = (nx) in (*nothing*)
end // end of [mynode_free]

implement{a}
mynode_free_elt
  (nx, res) = let
  val nx = mynode_decode (nx)
  val~DLNODE (x, _, _) = (nx); val () = res := x in (*nothing*)
end // end of [mynode_free_elt]

implement{a}
mynode_getfree_elt
  (nx) = let
  val nx = mynode_decode (nx)
  val~DLNODE (x, _, _) = (nx) in x
end // end of [mynode_getfree_elt]

(* ****** ****** *)

implement(a)
gnode_getref_elt<mytkind><a>
  (nx) = let
//
val nx = mynode_decode (nx)
//
val+@DLNODE (elt, _, _) = nx
val p_elt = addr@ (elt)
prval () = fold@ (nx)
prval () = dlnode_vfree (nx)
//
in
  p_elt
end // end of [gnode_getref_elt]

(* ****** ****** *)

implement(a)
gnode_getref_next<mytkind><a>
  (nx) = let
//
val nx = mynode_decode (nx)
//
val+@DLNODE (_, next, _) = nx
val p_next = addr@ (next)
prval () = fold@ (nx)
prval () = dlnode_vfree (nx)
//
in
  p_next
end // end of [gnode_getref_next]

(* ****** ****** *)

implement(a)
gnode_getref_prev<mytkind><a>
  (nx) = let
//
val nx = mynode_decode (nx)
//
val+@DLNODE (_, _, prev) = nx
val p_prev = addr@ (prev)
prval () = fold@ (nx)
prval () = dlnode_vfree (nx)
//
in
  p_prev
end // end of [gnode_getref_prev]

(* ****** ****** *)

(* end of [dllist.dats] *)
