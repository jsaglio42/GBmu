// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   lcd.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/26 18:34:11 by jsaglio           #+#    #+#             //
//   Updated: 2016/10/26 20:06:54 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;

class LCD extends Ser.RecursivelySerializable {

  /* Screen Double-buffer */
  List<int> screen = new List<int>(LCD_SIZE);
  List<int> screenBuffer = new List<int>(LCD_SIZE);

  /* Line Buffers */
  List<int> bgColorIDs = new List<int>(LCD_WIDTH);
  List<int> spriteColors = new List<int>(LCD_WIDTH);
  List<int> zBuffer = new List<int>(LCD_WIDTH);

  /* Drawing Info */
  bool shouldRefreshScreen;
  bool shouldDrawLine;

  /* API **********************************************************************/
  void reset() {
    Ft.fillBuffer(this.screen, 0x00);
  }

  void resetDrawingInfo() {
    this.shouldDrawLine = false;
    this.shouldRefreshScreen = false;
  }

  void refreshScreen() {
    List<int> tmp;

    tmp = this.screenBuffer;
    this.screenBuffer = this.screen;
    this.screen = tmp;
    return ;
  }

  void setPixel(int x, int y, int c) {
    this.screenBuffer[y * LCD_WIDTH + x] = c;
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('screen', () => screen,
          (v) => this.screen = new List<int>.from(v)),
      new Ser.Field('screenBuffer', () => screenBuffer,
          (v) => this.screenBuffer = new List<int>.from(v)),
      new Ser.Field('bgColorIDs', () => bgColorIDs,
          (v) => this.bgColorIDs = new List<int>.from(v)),
      new Ser.Field('spriteColors', () => spriteColors,
          (v) => this.spriteColors = new List<int>.from(v)),
      new Ser.Field('zBuffer', () => zBuffer,
          (v) => this.zBuffer = new List<int>.from(v)),
      new Ser.Field('shouldRefreshScreen', () => shouldRefreshScreen,
          (v) => shouldRefreshScreen),
      new Ser.Field('shouldDrawLine', () => shouldDrawLine,
          (v) => shouldDrawLine),
    ];
  }
}
