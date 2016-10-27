// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   canvas_scale.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/22 13:12:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/27 18:39:16 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of canvas;

// CONSTANTS **************************************************************** **
const double __MIN_SCALE = 1.0;
const double __MAX_SCALE = 10.0;
const double __DEFAULT_SCALE = 2.0;
const List<double> steps = const <double>[
  1.0, 2.0, 4.0, 10.0
];

// VARIABLE ***************************************************************** **
final Html.Element _text =
  Html.querySelector('.canvas-scale-part.slider-text');
double __screenScale;

double get _screenScale => __screenScale;

void set _screenScale(double s) {
  if (s != _screenScale) {
    __screenScale = s;
    _screen.width = (LCD_WIDTH * __screenScale) ~/ 1.0;
    _screen.height = (LCD_HEIGHT * __screenScale) ~/ 1.0;
    _text.text = '$s' + 'x';
    _refreshScreen();
    _screen.context2D.imageSmoothingEnabled = _smooth;
  }
}

class __Slider {

  // CONSTUCTION ************************************************************ **
  __Slider() {
    var constr = Js.context['Slider'];
    assert(constr != null, "Could not find `Slider` constructor");

    var param = new Js.JsObject.jsify({
      'formatter': _formatter,
      'min': __MIN_SCALE,
      'max': __MAX_SCALE,
      'value': __DEFAULT_SCALE,
      'step': 0.01,
      'ticks_snap_bounds': 0.05,
      'ticks': steps,
      'ticks_labels': steps.map((double d) => '$d' + 'x'),
      'ticks_positions': steps.map((double d) => _posOfScale(d)),
    });

    assert(param != null, "Could not build `Slider` parameter");
    var slider = new Js.JsObject(constr, [
      '.canvas-scale-part.slider-cont > .slider', param]);
    assert(slider != null, "Could not build `Slider`");

    slider.callMethod('on', ['slide', _onSlide]);
    slider.callMethod('on', ['slideStop', _onSlide]);
  }

  // PRIVATE **************************************************************** **
  void _onSlide(num scale) {
    _screenScale = scale;
  }

  double _posOfScale(double d) =>
    (d - __MIN_SCALE) / (__MAX_SCALE - __MIN_SCALE) * 100.0;

  String _formatter(num scale) =>
    'Screen scale ' + scale.toString() + 'x';

}

// CONSTRUCTION ************************************************************* **
void _init_scale() {
  _screenScale = __DEFAULT_SCALE;
  new __Slider();
}
