/* mpfr_mul_d -- multiply a multiple precision floating-point number
                 by a machine double precision float

Copyright 2007, 2008, 2009, 2010 Free Software Foundation, Inc.
Contributed by the Arenaire and Cacao projects, INRIA.

This file is part of the GNU MPFR Library.

The GNU MPFR Library is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

The GNU MPFR Library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public License
along with the GNU MPFR Library; see the file COPYING.LESSER.  If not, see
http://www.gnu.org/licenses/ or write to the Free Software Foundation, Inc.,
51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA. */

#include "mpfr-impl.h"

int
mpfr_mul_d (mpfr_ptr a, mpfr_srcptr b, double c, mpfr_rnd_t rnd_mode)
{
  int inexact;
  mpfr_t d;
  MPFR_SAVE_EXPO_DECL (expo);

  MPFR_LOG_FUNC (("b[%#R]=%R c=%.20g rnd=%d", b, b, c, rnd_mode),
                 ("a[%#R]=%R", a, a));

  MPFR_SAVE_EXPO_MARK (expo);

  mpfr_init2 (d, IEEE_DBL_MANT_DIG);
  inexact = mpfr_set_d (d, c, rnd_mode);
  MPFR_ASSERTN (inexact == 0);

  mpfr_clear_flags ();
  inexact = mpfr_mul (a, b, d, rnd_mode);
  MPFR_SAVE_EXPO_UPDATE_FLAGS (expo, __gmpfr_flags);

  mpfr_clear(d);
  MPFR_SAVE_EXPO_FREE (expo);
  return mpfr_check_range (a, inexact, rnd_mode);
}
