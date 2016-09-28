// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   canvas.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:37:10 by jsaglio           #+#    #+#             //
//   Updated: 2016/09/28 19:31:08 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import 'package:emulator/emulator.dart' as Emulator;

Emulator.Emulator _emu;

Html.CanvasElement _canvas = Html.querySelector('#gameboyScreen');
Html.CanvasElement _gameboyScreen = new Html.CanvasElement(
  width: LCD_WIDTH,
  height: LCD_HEIGHT);
Html.ImageData _idata = _gameboyScreen.context2D.createImageData(LCD_WIDTH, LCD_HEIGHT);

// Html.CanvasRenderingContext2D _context = _canvas.context2D;
// Html.ImageData _idata = _context.createImageData(LCD_WIDTH, LCD_HEIGHT);

// Html.querySelector('#gameboyScreen');
// Html.CanvasRenderingContext2D _context = _canvas.context2D;
// Html.ImageData _idata =  _context.createImageData

/* Can be used to change the size of the screen */
int _screenScale = 1;
int get screenScale => _screenScale;
void set screenScale(int s) {
  _screenScale = s.clamp(1, 3);
  _canvas.width = LCD_WIDTH * _screenScale;
  _canvas.height = LCD_HEIGHT * _screenScale;
  return ;
}

/* Init */
void init(Emulator.Emulator emu) {
  _emu = emu;
  var red = new List.filled(LCD_WIDTH * LCD_HEIGHT, 0xFF0000);
  var green = new List.filled(LCD_WIDTH * LCD_HEIGHT, 0x00FF00);
  var blue = new List.filled(LCD_WIDTH * LCD_HEIGHT, 0x0000FF); 
  var black = new List.filled(LCD_WIDTH * LCD_HEIGHT, 0x000000);
  screenScale = 1;
  print("*******  START *******");
  _drawListToScreen(red);

  // print('*** Start ***');

  // var start = new DateTime.now();
  // int i = 0;
  // for (i = 0; i < 1000; ++i) {
  //   if (i % 2 == 0)
  //     _drawListToScreen(red);
  //   else
  //     _drawListToScreen(green);
  // }
  // var now = new DateTime.now();
  // print(i * 1000000 / now.difference(start).inMicroseconds);
  // print('*** End ***');
  print("*******  STOP *******");
  return ;
}

/* Private ********************************************************************/
void _drawListToScreen(List<int> l) {
  assert(l.length == LCD_WIDTH * LCD_HEIGHT);
  for (int i = 0; i < LCD_WIDTH * LCD_HEIGHT; i++) {
    _idata.data[i] = l[i];
  }
  _canvas.context2D.drawImage(_gameboyScreen, 20, 20);
  // _context.drawImage(_idata, 20, 20);
  // _canvas.context2D.drawImage(_image, 0, 0);
  return ;
}

// void _drawPixel(int x, int y, int rgb){
//   _context
//     ..fillStyle = Ft.toColorString(rgb)
//     ..fillRect(x * screenScale, y * screenScale, screenScale, screenScale);
//   return ;
// }


      // else
      // {
      //   if(GPU._canvas.createImageData)
      //     GPU._scrn = GPU._canvas.createImageData(160,144);
      //   else if(GPU._canvas.getImageData)
      //     GPU._scrn = GPU._canvas.getImageData(0,0,160,144);
      //   else
      //     GPU._scrn = {'width':160, 'height':144, 'data':new Array(160*144*4)};

      //   for(i=0; i<GPU._scrn.data.length; i++)
      //     GPU._scrn.data[i]=255;

      //   GPU._canvas.putImageData(GPU._scrn, 0,0);
      // }
