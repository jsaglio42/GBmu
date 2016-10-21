// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphicdisplay.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/21 17:53:58 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;

import "package:emulator/src/video/sprite.dart";
import "package:emulator/src/video/tile.dart";
import "package:emulator/src/video/tileinfo.dart";

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
    if (!this.memr.rLCDC.isBackgroundDisplayEnabled)
      return (null);
    final int posY = (y + this.memr.SCY) & 0xFF;
    final int posX =  (x + this.memr.SCX) & 0xFF;
    return (_getMappedColorID(posX, posY, this.memr.rLCDC.tileMapID_BG));
  }

  int _getWindowColorID(int x, int y) {
    final int posY = y - this.memr.WY;
    final int posX =  x - (this.memr.WX - 7);
    return (_getMappedColorID(posX, posY, this.memr.rLCDC.tileMapID_WIN));
  }

  int _getMappedColorID(int mapX, int mapY, int tileMapID) {
    final int tileX = mapX ~/ 8;
    final int tileY = mapY ~/ 8;
    final int relativeX = mapX % 8;
    final int relativeY = mapY % 8;
    final int tileID = this.videoram.getTileID(tileX, tileY, tileMapID);
    final TileInfo tinfo = this.videoram.getTileInfo(tileX, tileY, tileMapID);
    final Tile tile = this.videoram.getTile(tileID, tinfo.bankID, tileMapID);
    return tile.getColorID(relativeX, relativeY, tinfo.flipX, tinfo.flipY);
  }

  void _setSpriteColors(int y) {
    if (!this.memr.rLCDC.isSpriteDisplayEnabled)
      return ;
    Ft.fillBuffer(this.lcd.zBuffer, -1);

    final int sizeY = this.memr.rLCDC.spriteSize;
    for (int spriteno = 0; spriteno < 40; ++spriteno) {
      Sprite s = this.oam[spriteno];

      int relativeY = y - (s.posY - 16);
      if (relativeY < 0 || relativeY >= sizeY)
        continue ;
      else if (s.info.flipY)
        relativeY = sizeY - 1 - relativeY;

      int tileID;
      if (relativeY < 8)
        tileID = s.tileID & 0xFE;
      else
      {
        relativeY -= 8; 
        tileID = s.tileID | 0x01;
      }

      final Tile tile = this.videoram.getTile(tileID, s.info.bankID, 0);

      for (int relativeX = 0; relativeX < 8; ++relativeX) {
        int x = (s.posX - 8) + relativeX;
        if (x >= LCD_WIDTH)
          break ;
        else if (x < 0
          || this.lcd.zBuffer[x] >= 0
          || (s.info.priorityIsBG && this.lcd.bgColorIDs[x] != 0 && this.lcd.bgColorIDs[x] != null))
          continue ;
        final int colorID = tile.getColorID(relativeX, relativeY, s.info.flipX, s.info.flipY);
        final int OBP = (s.info.OBP_DMG == 0) ? this.memr.OBP0 : this.memr.OBP1;
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
