// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 14:30:43 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/26 15:31:09 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:convert' as Conv;
import 'dart:math' as Math;

const int GB_CPU_FREQ_INT = 4194304; // clock / second

class _CustomLogScale extends Conv.Codec<double, double> {

  final double _base;
  final double _exponentPreAdd;
  final double _exponentMult;
  final double _exponentPostAdd;
  final double _resultPreAdd;
  final double _resultMult;
  final double _resultPostAdd;

  const _CustomLogScale(
      this._base,
      this._exponentPreAdd, this._exponentMult, this._exponentPostAdd,
      this._resultPreAdd, this._resultMult, this._resultPostAdd);

  double decode(double percent)
  {
    final double exponent =
      (percent + _exponentPreAdd) * _exponentMult + _exponentPostAdd;
    final double pow = Math.pow(_base, exponent);
    final double res = (pow + _resultPreAdd) * _resultMult + _resultPostAdd;

    return res;
  }

  double encode(double speed)
  {
    final double logarg =
      (speed - _resultPostAdd) / _resultMult - _resultPreAdd;
    final double log =
      Math.log(logarg) / Math.log(_base);
    final double res =
      (log - _exponentPostAdd) / _exponentMult - _exponentPreAdd;

    return res;
  }

}

/** A monotonic converter Codec<double, double> that maps `percents` [0.0, 1.0]
 **  to speed [0.0, 100.0].
 ** Speed | Percent
 ** 0x    | 0%
 ** 1x    | 50%
 ** 100x  | 100%
 **/
class _FiniteEmulationSpeedCodec extends Conv.Codec<double, double> {

  static final double FREQ = GB_CPU_FREQ_INT.toDouble();
  static final double FREQ_LOG10 = Math.log(FREQ) / Math.log(10.0);
  static final double TWO_FREQ_LOG10 = 2.0 * FREQ_LOG10;
  static final double ONEOVER_FREQ = 1.0 / FREQ;
  static final double CORRECTION = FREQ / (FREQ - 1.0);

  static final _FIRST_HALF_CODEC = new _CustomLogScale(
      10.0,
      0.0, TWO_FREQ_LOG10, 0.0,
      -1.0, ONEOVER_FREQ * CORRECTION, 0.0);
  static final _SECOND_HALF_CODEC = new _CustomLogScale(
      100.0,
      0.0, 2.0, 0.0,
      0.0, 1.0 / 100.0, 0.0);

  double decode(double percent)
  {
    // assert(!(percent < 0.0) && !(percent > 1.0),
    //     '_FiniteEmulationSpeedCodec.decode($percent) out of range');
    if (percent > 0.5)
      return _SECOND_HALF_CODEC.decode(percent);
    else
      return _FIRST_HALF_CODEC.decode(percent);
  }

  double encode(double speed)
  {
    // assert(!(speed < 0.0) && !(speed > 100.0),
    //     '_FiniteEmulationSpeedCodec.encode($speed) out of range');
    if (speed > 1.0)
      return _SECOND_HALF_CODEC.encode(speed);
    else
      return _FIRST_HALF_CODEC.encode(speed);
  }
}

/** Same codec as above, but binds `1.0 percent` to `INFINITY` **/
class _InfiniteEmulationSpeedCodec extends Conv.Codec<double, double> {

  static final _FINITE_CODEC = new _FiniteEmulationSpeedCodec();

  double decode(double percent)
  {
    // assert(!(percent < 0.0) && !(percent > 1.0),
        // '_InfiniteEmulationSpeedCodec.decode($percent) out of range');
    if (percent < 1.0)
      return _FINITE_CODEC.decode(percent);
    else
      return double.INFINITY;
  }

  double encode(double speed)
  {
    if (speed.isFinite) {
      // assert(!(speed < 0.0) && speed < 100.0,
      //     '_InfiniteEmulationSpeedCodec.encode($speed) out of range');
      return _FINITE_CODEC.encode(speed);
    }
    else
      return 1.0;
  }
}

final _InfiniteEmulationSpeedCodec codec =
  new _InfiniteEmulationSpeedCodec();

main () {
  print('hello world');
  for (double d = 0.0; d < 1.01; d += 0.025) {
    var s = codec.decode(d);
    var d2 = codec.encode(s);
    print('$d -> $s \n$d2\n');
  }
}