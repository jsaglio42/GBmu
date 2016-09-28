// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   canvas.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:37:10 by jsaglio           #+#    #+#             //
//   Updated: 2016/09/28 22:47:19 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import 'package:emulator/emulator.dart' as Emulator;

Emulator.Emulator _emu;

Html.CanvasElement _screen = Html.querySelector('#gameboyScreen');
Html.CanvasElement _unscaledScreen = new Html.CanvasElement(width: LCD_WIDTH, height: LCD_HEIGHT);
Html.ImageData _unscaledImageData = _unscaledScreen.context2D.createImageData(LCD_WIDTH, LCD_HEIGHT);

/* Can be used to change the size of the screen */
int _screenScale = 1;
int get screenScale => _screenScale;
void set screenScale(int s) {
  _screenScale = s.clamp(1, 3);
  _screen.width = LCD_WIDTH * _screenScale;
  _screen.height = LCD_HEIGHT * _screenScale;
  _refreshScreen();
  return ;
}

/* Init */
void init(Emulator.Emulator emu) {
  _emu = emu;
  _drawListToScreen(new List.filled(LCD_WIDTH * LCD_HEIGHT, 0));
  screenScale = 2;

  /* Tests */
  var striped = new List.generate(LCD_WIDTH * LCD_HEIGHT, (i) => (i % 2 == 0) ? 0xFF0000 : 0x0000FF);
  _drawListToScreen(striped);
  return ;
}

/* Private ********************************************************************/
void _drawListToScreen(List<int> l) {
  var data = _unscaledImageData.data;
  assert(l.length * 4 == data.length, "_drawListToScreen: Length difference");
  for (int i = 0; i < LCD_WIDTH * LCD_HEIGHT; i++) {
    data[4 * i + 0] = (l[i] >> 16) & 0xFF; //red
    data[4 * i + 1] = (l[i] >> 8) & 0xFF; //green
    data[4 * i + 2] = (l[i] >> 0) & 0xFF; //blue
    data[4 * i + 3] = 0xFF; //alpha
  }
  _unscaledScreen.context2D.putImageData(_unscaledImageData, 0, 0);
  _refreshScreen();
  return ;
}

void _refreshScreen() {
  _screen.context2D.drawImageScaled(_unscaledScreen, 0, 0
    , _screen.width, _screen.height);
  return ;
}
