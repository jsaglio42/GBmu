// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   lcd.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/26 18:34:11 by jsaglio           #+#    #+#             //
//   Updated: 2016/10/19 16:26:46 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

class LCD {

  /* Screen Double-buffer */
  List<int> screen = new List<int>(LCD_SIZE);
  List<int> screenBuffer = new List<int>(LCD_SIZE);

  /* Line Buffers */
  List<int> bgColorIDs = new List<int>(LCD_WIDTH);
  List<int> spriteColors = new List<int>(LCD_WIDTH);
  List<int> zBuffer = new List<int>(LCD_WIDTH);

  /* Drawing Info */
  bool shouldRefreshScreen;

  bool _shouldDrawLine;
  bool get shouldDrawLine => _shouldDrawLine;

  int _lineNo;
  int get lineNo => _lineNo;

  /* API **********************************************************************/
  void reset() {
    Ft.fillBuffer(this.screen, 0x00);
  }

  void requestDrawLine(int line) {
    _shouldDrawLine = true;
    _lineNo = line;
  }

  void resetDrawingInfo() {
    this.shouldRefreshScreen = false;
    _shouldDrawLine = false;

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


}


