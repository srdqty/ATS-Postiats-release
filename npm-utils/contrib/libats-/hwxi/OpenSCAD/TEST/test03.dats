(* ****** ****** *)
(*
** An example of
** ATS and OpenSCAD co-programming
*)
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
#include
"share/HATS\
/atspre_staload_libats_ML.hats"
//
(* ****** ****** *)
//
#staload
"libats/libc/SATS/math.sats"
#staload _ =
"libats/libc/DATS/math.dats"
//
(* ****** ****** *)
//
#include "./../mylibies.hats"
//
#staload $OpenSCAD // opening it!
#staload $OpenSCAD_meta // opening it!
//
#include "./../mylibies_link.hats"
//
(* ****** ****** *)
//
fun
ballrow
{n:pos}
(
  ball: scadobj, n: int(n)
) : scadobj =
(
if n = 1
  then ball
  else
  scadobj_union2
  ( ball
  , scadobj_translate(2.0, 0.0, 0.0, ballrow(ball, n-1))
  ) (* scadobj_union2 *)
)
//
fun
ballrows
{m,n:pos}
(
  ball: scadobj, m: int(m), n: int(n)
) : scadobj =
(
if m = 1
  then ballrow(ball, n)
  else
  scadobj_union2
  ( ballrow(ball, n)
  , scadobj_translate(0.0, 2.0, 0.0, ballrows(ball, m-1, n))
  ) (* scadobj_union2 *)
)
//
(* ****** ****** *)

fun
ballstack
{n:pos}
(
  ball: scadobj, n: int(n)
) : scadobj =
(
if n = 1
  then ball
  else let
    val stack = ballstack(ball, n-1)
    val bottom = ballrows(ball, n, n)
  in
    scadobj_union2(scadobj_translate(1.0, 1.0, sqrt(2.0), stack), bottom)
  end // end of [else]
)

(* ****** ****** *)
//
implement
main0() = () where
{
//
#define N 5
//
val out = stdout_ref
//
val stack =
ballstack
  (scadobj_sphere(1.0), N)
val stack =
scadobj_translate(~1.0*N+1.0, ~1.0*N+1.0, 1.0, stack)
//
val () =
fprintln!
(out, "\
/*
The code is automatically
generated from [test03.dats]
*/\n\
")
val () =
fprintln!
(out, "$fa=0.1; $fs=0.1;\n")
//
val () =
scadobj_femit(out, 0(*nsp*), stack)
//
val () =
fprint! (out, "\n")
val () =
fprintln!
(out, "/* end of [test03_dats.scad] */")
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [test03.dats] *)
