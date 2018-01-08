(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "share/atspre_staload_libats_ML.hats"

(* ****** ****** *)
//
// HX: for [intsqrt] based on [sqrt]:
//
#staload M = "libats/libc/SATS/math.sats"
#staload _(*M*) = "libats/libc/DATS/math.dats"
//
(* ****** ****** *)

(*
//
// HX-2018-01-08:
// The following Haskell code taken from
// http://blog.vmchale.com/article/ats-totient
//
hsIsPrime :: (Integral a) => a -> Bool
hsIsPrime 1 = False
hsIsPrime x = all ((/=0) . (x mod)) [2..m]
    where m = floor (sqrt (fromIntegral x :: Float))
hsTotient :: (Integral a) => a -> a
hsTotient n = (n * product [ p - 1 | p <- ps ]) div product ps
    where ps = filter (\k -> hsIsPrime k && n mod k == 0) [2..n]
*)

(* ****** ****** *)
//
fun
atsIsPrime(x: intGt(0)): bool =
  case+ x of
  | 1 => false
  | _ =>>
    intrange_forall(2, $M.intsqrt(x)+1)
    where { implement intrange_forall$pred<>(i) = x % i > 0 }
// end of [atsIsPrime]
//
(* ****** ****** *)

(*
//
// HX-2018-01-08:
// [atsTotient] is memory-clean:
//
*)

fun
atsTotient(n: intGt(0)): int =
  if
  atsIsPrime(n)
  then n-1
  else let
    val ks =
    $UNSAFE.castvwtp0
    {stream_vt(intGt(0))}(stream_vt_make_intrange_lr(2, n))
    val ps =
    stream2list_vt(stream_vt_filter_cloptr(ks, lam(k) => atsIsPrime(k)))
    val totient =
    list_vt_foldleft_cloptr<int><int>(ps, n, lam(r, p) => if n%p=0 then (r/p)*(p-1) else r)
  in
    list_vt_free(ps); totient
  end

(* ****** ****** *)

implement main0() = println! ("totient(1000000) = ", atsTotient(1000000))

(* ****** ****** *)

(* end of [totient.dats] *)
