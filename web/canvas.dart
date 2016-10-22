// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   canvas.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:37:10 by jsaglio           #+#    #+#             //
//   Updated: 2016/10/22 14:22:20 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library canvas;

import 'dart:typed_data';
import 'dart:html' as Html;
import 'dart:js' as Js;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

part './canvas_scale.dart';
part './canvas_smooth.dart';

Emulator.Emulator _emu;
Html.CanvasElement _screen = Html.querySelector('#gameboyScreen');

Html.CanvasElement _unscaledScreen =
  new Html.CanvasElement(width: LCD_WIDTH, height: LCD_HEIGHT);
Html.ImageData _unscaledImageData =
  _unscaledScreen.context2D.createImageData(LCD_WIDTH, LCD_HEIGHT);

/* Init */
void init(Emulator.Emulator emu) {
  _emu = emu;
  _turnOffScreen();
  _init_scale();
  _init_smooth();
  _emu.listener('FrameUpdate').forEach(_updateScreen);
  return ;
}

/* Private ********************************************************************/
/* Screen Size */
/* Screen content */
  final List<List<int>> _colorDecoder = new List.unmodifiable([
    [0xFF, 0xFF, 0xFF, 0xFF], // White
    [0xAA, 0xAA, 0xAA, 0xFF], // Light Grey
    [0x55, 0x55, 0x55, 0xFF], // Dark Grey
    [0x00, 0x00, 0x00, 0xFF]  // Black
  ]);

void _updateScreen(List<int> screen) {
  var data = _unscaledImageData.data;
  assert(data.length == LCD_DATA_SIZE, "_updateScreen: Invalid Data");
  assert(screen.length == LCD_SIZE, "_updateScreen: Invalid Screen");
  for (int i = 0; i < LCD_SIZE; ++i)
  {
    List<int> color = _colorDecoder[screen[i]];
    data[4 * i + 0] = color[0];
    data[4 * i + 1] = color[1];
    data[4 * i + 2] = color[2];
    data[4 * i + 3] = color[3];
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
  List<int> black = new List<int>.filled(LCD_SIZE, 0x3);
  _updateScreen(black);
  return ;
}
