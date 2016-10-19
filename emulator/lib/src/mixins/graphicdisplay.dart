// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphicdisplay.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 20:34:02 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/hardware/oam.dart" as Oam;

abstract class GraphicDisplay
  implements Hardware.Hardware {

  /* API **********************************************************************/
  void updateDisplay() {
      if (this.lcd.shouldDrawLine)
        _drawLine();
      if (this.lcd.shouldRefreshScreen)
        this.lcd.refreshScreen();
    return ;
  }

  /* Drawing functions ********************************************************/
  void _drawLine() {
    Ft.fillBuffer(this.lcd.bgColorIDs, null);
    Ft.fillBuffer(this.lcd.spriteColors, null);

    final int y = this.lcd.lineNo;
    for (int x = 0; x < LCD_WIDTH; ++x)
    {
      this.lcd.bgColorIDs[x] = _useWindowColorID(x, y)
        ? _getWindowColorID(x, y)
        : _getBackgroundColorID(x, y);
    }
    _setSpriteColors(y);
    _updateScreenBuffer(y);
    return ;
  }

  int _getBackgroundColorID(int x, int y) {
    // print('Background');
    if (!this.memr.rLCDC.isBackgroundDisplayEnabled)
      return (null);
    final int posY = (y + this.memr.SCY) & 0xFF;
    final int posX =  (x + this.memr.SCX) & 0xFF;
    final int tileY = posY ~/ 8;
    final int tileX = posX ~/ 8;
    final int tileIDAddress = _getTileIDAddress(tileX, tileY, this.memr.rLCDC.tileMapID_BG);
    
    final int tileID = this.videoRam.pull8(tileIDAddress);
    final int tileAddress = _getTileAddress(tileID, this.memr.rLCDC.tileDataID);
    final int relativeY = posY % 8;
    final int relativeX = posX % 8;
    final int tileRow_l = this.videoRam.pull8(tileAddress + relativeY * 2);
    final int tileRow_h = this.videoRam.pull8(tileAddress + relativeY * 2 + 1);
    final int colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
    final int colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
    return (colorId_l | colorId_h);
  }

  int _getWindowColorID(int x, int y) {
    // print('Window');
    final int posY = y - this.memr.WY;
    final int posX =  x - (this.memr.WX - 7);
    final int tileY = posY ~/ 8;
    final int tileX = posX ~/ 8;
    final int tileIDAddress = _getTileIDAddress(tileX, tileY, this.memr.rLCDC.tileMapID_WIN);
    
    final int tileID = this.videoRam.pull8(tileIDAddress);
    final int tileAddress = _getTileAddress(tileID, this.memr.rLCDC.tileDataID);
    final int relativeY = posY % 8;
    final int relativeX = posX % 8;
    final int tileRow_l = this.videoRam.pull8(tileAddress + relativeY * 2);
    final int tileRow_h = this.videoRam.pull8(tileAddress + relativeY * 2 + 1);
    final int colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
    final int colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
    return (colorId_l | colorId_h);
  }

  void _setSpriteColors(int y) {
    if (!this.memr.rLCDC.isSpriteDisplayEnabled)
      return ;
    Ft.fillBuffer(this.lcd.zBuffer, -1);
    final int sizeY = this.memr.rLCDC.spriteSize;
    for (int spriteno = 0; spriteno < 40; ++spriteno) {
      Oam.Sprite s = this.oam[spriteno];

      int relativeY = y - (s.posY - 16);
      if (relativeY < 0 || relativeY >= sizeY)
        continue ;
      else if (s.flipY)
        relativeY = sizeY - 1 - relativeY;


      final int tileID = s.tileID;
      final int tileAddress = 0x8000 + tileID * 16; // tile address should use sizeY ? TO BE CHECKED
      final int tileRow_l = this.videoRam.pull8(tileAddress + relativeY * 2);
      final int tileRow_h = this.videoRam.pull8(tileAddress + relativeY * 2 + 1);

      for (int relativeX = 0; relativeX < 8; ++relativeX) {
        int x = (s.posX - 8) + relativeX;
        if (x >= LCD_WIDTH)
          break ;
        else if (x < 0
          || this.lcd.zBuffer[x] >= 0
          || (s.priorityIsBG && this.lcd.bgColorIDs[x] != 0 && this.lcd.bgColorIDs[x] != null))
          continue ;

        int colorId_l;
        int colorId_h;
        if (s.flipX)
        {
          colorId_l = (tileRow_l >> relativeX) & 0x1 == 1 ? 0x1 : 0x0;
          colorId_h = (tileRow_h >> relativeX) & 0x1 == 1 ? 0x2 : 0x0;
        }
        else
        {
          colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
          colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
        }

        final int colorID = colorId_l | colorId_h;
        if (colorID == 0)
          continue;
        final int OBP = (s.OBP_DMG == 0) ? this.memr.OBP0 : this.memr.OBP1;
        this.lcd.spriteColors[x] = _getColor(colorID, OBP);
        this.lcd.zBuffer[x] = spriteno;
      }

    }
  }

  void _updateScreenBuffer(int y) {
    assert(this.lcd.bgColorIDs.length == LCD_WIDTH, 'Failure');
    assert(this.lcd.spriteColors.length == LCD_WIDTH, 'Failure');
    final int BGP = this.memr.BGP;
    for (int x = 0; x < LCD_WIDTH; ++x)
    {
      if (this.lcd.spriteColors[x] != null)
        this.lcd.setPixel(x, y, this.lcd.spriteColors[x]);
      else
        this.lcd.setPixel(x, y, _getColor(this.lcd.bgColorIDs[x], BGP));
    }
    return ;
  }

 /*****************************************************************************/ 
 int _getTileAddress(int tileID, int tileDataID) {
    assert(tileID & ~0xFF == 0, 'Invalid tileID');
    assert(tileDataID & ~0x3 == 0, 'Invalid tileID');    
    if (tileDataID == 1)
      return 0x8000 + tileID * 16;
    else
      return 0x9000 + tileID.toSigned(8) * 16;
  }

  int _getTileIDAddress(int tileX, int tileY, int tileMapID) {
    assert(tileX < 32, 'Invalid tileX');
    assert(tileY < 32, 'Invalid tileY');
    assert(tileMapID & ~0x3 == 0, 'Invalid tileID');
    if (tileMapID == 1)
      return 0x9C00 + 32 * tileY + tileX;
    else
      return 0x9800 + 32 * tileY + tileX;
  }

  int _getColor(int colorID, int palette) {
    if (colorID == null)
      return 0x00;
    else
      return (palette >> (2 * colorID)) & 0x3;
  }

  bool _useWindowColorID(int x, int y) {
    if (!this.memr.rLCDC.isWindowDisplayEnabled)
      return false;
    final int posY = y - this.memr.WY;
    if (posY < 0 || posY >= LCD_HEIGHT)
      return false;
    final int posX =  x - (this.memr.WX - 7);
    if (posX < 0 || posX >= LCD_WIDTH)
      return false;
    return true;
  }

}
