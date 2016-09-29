// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   canvas.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:37:10 by jsaglio           #+#    #+#             //
//   Updated: 2016/09/29 11:40:44 by jsaglio          ###   ########.fr       //
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
Html.DivElement _screenSize = Html.querySelector('#screenSizeRadioButtons');

Html.CanvasElement _unscaledScreen =
  new Html.CanvasElement(width: LCD_WIDTH, height: LCD_HEIGHT);
Html.ImageData _unscaledImageData =
  _unscaledScreen.context2D.createImageData(LCD_WIDTH, LCD_HEIGHT);

/* Ued to change the size of the screen */
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
  _turnOffScreen();
  screenScale = 2;
  _emu.listener('FrameUpdate').forEach(_updateScreen);
  _screenSize.onChange.forEach(_onRadioUpdate);
  return ;
}

/* Private ********************************************************************/
/* Screen Size */
void _onRadioUpdate(_) {
    _screenSize.children.forEach(
      (l) {
        var input = l.children[0];
        if (input.checked)
          screenScale = int.parse(input.value);
      });
}

/* Screen content */
void _updateScreen(Uint8List l) {
  var data = _unscaledImageData.data;
  assert(data.length == LCD_DATA_SIZE, "_updateScreen: Invalid Data");
  assert(l.length == data.length, "_updateScreen: Invalid Data");
  for (int i = 0; i < data.length; i++) {
    data[i] = l[i];
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

void _turnOffScreen() {
  Uint8List black = new Uint8List(LCD_DATA_SIZE);
  for (int i = 0; i < black.length; i++) {
    if (i % 4 == 3) { black[i] = 0xFF; }
  }
  _updateScreen(black);
  return ;
}
