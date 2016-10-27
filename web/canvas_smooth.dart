// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   canvas_smooth.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/22 14:21:51 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/27 19:49:30 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of canvas;

// CONSTANTS **************************************************************** **
const bool __DEFAULT_SMOOTH = false;
const String __LOCAL_STORAGE_KEY_SMOOTH = 'option_smooth';

// VARIABLE ***************************************************************** **
final Html.Element _textSmooth =
  Html.querySelector('.canvas-smooth-part.slider-text');
bool __smooth;

bool get _smooth => __smooth;

void set _smooth(bool b) {
  if (b != __smooth) {
    __smooth = b;
    Html.window.localStorage[__LOCAL_STORAGE_KEY_SMOOTH] = b.toString();
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
      'value': (_smooth ? 1.0 : 0.0),
      'ticks': [0.0, 1.0],
      'ticks_positions': [0, 100],
    });

    assert(param != null, "Could not build `Slider` parameter");
    var slider = new Js.JsObject(constr, [
      '.canvas-smooth-part.slider-cont > .slider', param]);
    assert(slider != null, "Could not build `Slider`");

    slider.callMethod('on', ['slide', _onSlide]);
    slider.callMethod('on', ['slideStop', _onSlide]);
  }

  // PRIVATE **************************************************************** **
  void _onSlide(num n) {
    _smooth = n > 0.5;
  }

}


// CONSTRUCTION ************************************************************* **
void _init_smooth() {
  final String prevValOpt =
    Html.window.localStorage[__LOCAL_STORAGE_KEY_SMOOTH];
  bool val;

  if (prevValOpt == 'true')
    val = true;
  else if (prevValOpt == 'false')
    val = false;
  else
    val = __DEFAULT_SMOOTH;
  _smooth = val;
  new __SmoothSlider();
}
