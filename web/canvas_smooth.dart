// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   canvas_smooth.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/22 14:21:51 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/22 16:24:15 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of canvas;

// CONSTANTS **************************************************************** **
const bool __DEFAULT_SMOOTH = false;

// VARIABLE ***************************************************************** **
final Html.Element _textSmooth =
  Html.querySelector('.canvas-smooth-part.slider-text');
bool __smooth;

bool get _smooth => __smooth;

void set _smooth(bool b) {
  if (b != __smooth) {
    __smooth = b;
    _textSmooth.text = _smoothFormatter(b);
    _screen.context2D.imageSmoothingEnabled = b;
  }
}

String _smoothFormatter(bool b) =>
  'Anti-aliasing ' + (b ? 'On' : 'Off');

String _smoothFormatterNum(num n) =>
  _smoothFormatter(n > 0.5);

class __SmoothSlider {

  // CONSTUCTION ************************************************************ **
  __SmoothSlider() {
    var constr = Js.context['Slider'];
    assert(constr != null, "Could not find `Slider` constructor");

    var param = new Js.JsObject.jsify({
      'formatter': _smoothFormatterNum,
      'min': 0.0,
      'max': 1.0,
      'value': 0.0,
      'ticks': [0.0, 1.0],
      // 'ticks_labels': ['Off', 'On'],
      'ticks_positions': [0, 100],
    });

    assert(param != null, "Could not build `Slider` parameter");
    var slider = new Js.JsObject(constr, [
      '.canvas-smooth-part.slider-cont > .slider', param]);
    assert(slider != null, "Could not build `Slider`");

    slider.callMethod('on', ['slide', _onSlide]);
  }

  // PRIVATE **************************************************************** **
  void _onSlide(num n) {
    _smooth = n > 0.5;
  }

}


// CONSTRUCTION ************************************************************* **
void _init_smooth() {
  _smooth = __DEFAULT_SMOOTH;
  new __SmoothSlider();
}
