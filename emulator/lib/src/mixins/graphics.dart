// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphics.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/17 15:33:54 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/mixins/interruptmanager.dart" as Interrupt;
import "package:emulator/src/mixins/tail_ram.dart" as Tailram;
import "package:emulator/src/mixins/mmu.dart" as Mmu;

enum GraphicMode {
  HBLANK,
  VBLANK,
  OAM_ACCESS,
  VRAM_ACCESS
}

enum GraphicInterrupt {
  HBLANK,
  VBLANK,
  OAM_ACCESS,
  COINCIDENCE
}

/* Small classes used to save updated info ************************************/
class GRegisterUpdatedInfo {

    GRegisterUpdatedInfo();

    bool drawLine = false;
    bool updateScreen = false;

    int LY = null;
    GraphicMode mode = null;
    int STAT = null;

    void reset() {
      this.drawLine = false;
      this.updateScreen = false;
      this.mode = null;
      this.STAT = null;
      this.LY = null;
      return ;
    }

}

/* Mixins that handle graphics ************************************************/
abstract class TrapAccessors {

  void setLCDCRegister(int v);
  void resetLYRegister();
  void execDMA(int v);

}

abstract class Graphics
  implements Hardware.Hardware
  , Tailram.TailRam
  , Mmu.Mmu
  , Interrupt.InterruptManager
  , TrapAccessors {
  
  int _counterScanline = 0;
  GRegisterUpdatedInfo _updated = new GRegisterUpdatedInfo();

  List<int> _screenBuffer = new List<int>(LCD_SIZE);

  List<int> _colorIDs_BG = new List<int>(LCD_WIDTH);
  List<int> _colors_Sprite = new List<int>(LCD_WIDTH);
  List<int> _zBuffer = new List<int>(LCD_WIDTH);

  /* API **********************************************************************/
  void updateGraphics(int nbClock) {
    _updated.reset();

    if (this.memr.rLCDC.isLCDEnabled)
    {
      _updateGraphicMode(nbClock);
      if (_updated.drawLine)
        _drawLine();
      if (_updated.updateScreen)
        _updateScreen();
      _updateGraphicRegisters();
    }
    return ;
  }

  void setLCDCRegister(int v) {
    if (!this.memr.rLCDC.isLCDEnabled && ((v >> 7) & 0x1 == 1))
    {
      _counterScanline = 0;
      this.memr.LY = 0;
      this.memr.STAT = ((this.memr.STAT & ~0x3) | 0x2) & 0xFF;
    }
    this.memr.LCDC = v;
    return ;
  }

  void resetLYRegister() {
    this.memr.LY = 0;
    return ;
  }

  void execDMA(int v) {
    final int addr = v * 0x100;

    for (int i = 0 ; i < 0xA0; i++) {
      this.tr_push8(0xFE00 + i, this.pull8(addr + i)); // to be changed with struct OAM
    }
    this.memr.DMA = v;
    return ;
  }

  /* Private ******************************************************************/
  void _updateGraphicMode(int nbClock) {
    _counterScanline += nbClock;
    switch (this.memr.rSTAT.mode)
    {
      case (GraphicMode.OAM_ACCESS) : _OAM_routine(); break;
      case (GraphicMode.VRAM_ACCESS) : _VRAM_routine(); break;
      case (GraphicMode.HBLANK) : ; _HBLANK_routine(); break;
      case (GraphicMode.VBLANK) : ; _VBLANK_routine(); break;
      default: assert (false, 'GraphicMode: switch failure');
    }
    // assert(_updated.LY != null, "LY: Condition Failure");
    // assert(_updated.mode != null, "Mode: Condition Failure");
  }

  /* Switch to VRAM_ACCESS or remain as is */
  void _OAM_routine() {
    if (_counterScanline >= CLOCK_PER_OAM_ACCESS)
    {
      _counterScanline -= CLOCK_PER_OAM_ACCESS;
      // _updated.LY = this.memr.LY;
      _updated.mode = GraphicMode.VRAM_ACCESS;
    }
    // else
    // {
    //   _updated.LY = this.memr.LY;
    //   _updated.mode = this.memr.rSTAT.mode;
    // }
  }

  /* Switch to HBLANK or remain as is */
  void _VRAM_routine() {
    if (_counterScanline >= CLOCK_PER_VRAM_ACCESS)
    {
      _counterScanline -= CLOCK_PER_VRAM_ACCESS;
      // _updated.LY = this.memr.LY;
      _updated.mode = GraphicMode.HBLANK;
        if (this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.HBLANK))
          this.requestInterrupt(InterruptType.LCDStat);
    }
    // else
    // {
    //   _updated.LY = this.memr.LY;
    //   _updated.mode = this.memr.rSTAT.mode;
    // }
  }

  /* Switch to OAM_ACCESS/VBLANK or remain as is */
  void _HBLANK_routine() {
    if (_counterScanline >= CLOCK_PER_HBLANK)
    {
      _counterScanline -= CLOCK_PER_HBLANK;
      _updated.drawLine = true;
      _updated.LY = this.memr.LY + 1;
      if (_updated.LY < VBLANK_THRESHOLD)
      {
        _updated.mode = GraphicMode.OAM_ACCESS;
        if (this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.OAM_ACCESS))
          this.requestInterrupt(InterruptType.LCDStat);
      }
      else
      {
        _updated.mode = GraphicMode.VBLANK;
        if (this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.VBLANK))
          this.requestInterrupt(InterruptType.LCDStat);
        this.requestInterrupt(InterruptType.VBlank);
      }

    }
    // else
    // {
    //   _updated.LY = this.memr.LY;
    //   _updated.mode = this.memr.rSTAT.mode;
    // }
  }

  /* Switch to OAM_ACCESS or remain as is */
  void _VBLANK_routine() {
    if (_counterScanline >= CLOCK_PER_LINE)
    {
      _counterScanline -= CLOCK_PER_LINE;
      final int incLY = this.memr.LY + 1;
      if (incLY >= FRAME_THRESHOLD)
      {
        _updated.updateScreen = true;
        _updated.LY = 0;
        _updated.mode = GraphicMode.OAM_ACCESS;
        if (this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.OAM_ACCESS))
          this.requestInterrupt(InterruptType.LCDStat);
      }
      else
      {
        _updated.LY = incLY;
        _updated.mode = this.memr.rSTAT.mode;
      }
    }
    // else
    // {
    //   _updated.LY = this.memr.LY;
    //   _updated.mode = this.memr.rSTAT.mode;
    // }
  }

  /* MUST trigger LYC interrupt and push new STAT/LY register */
  void _updateGraphicRegisters() {
    final int interrupt_bits = this.memr.STAT & 0xF8;
    final int mode_bits = (_updated.mode == null)
      ? this.memr.rSTAT.mode.index
      : _updated.mode.index;
    if (this.memr.LYC != _updated.LY)
      _updated.STAT = mode_bits | interrupt_bits;
    else
    {
      _updated.STAT = mode_bits | interrupt_bits | 0x4;
      if (this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.COINCIDENCE))
          this.requestInterrupt(InterruptType.LCDStat);
    }
    this.memr.STAT = _updated.STAT;
    if (_updated.LY != null)
      this.memr.LY = _updated.LY;
    return ;
  }

  /* Drawing functions ********************************************************/
  void _updateScreen() {
    List<int> tmp;

    // print('UpdateScreen');
    tmp = _screenBuffer;
    _screenBuffer = this.lcdScreen;
    this.lcdScreen = tmp;
    return ;
  }

  void _drawLine() {
    _colorIDs_BG.fillRange(0, _colorIDs_BG.length, null);
    _colors_Sprite.fillRange(0, _colors_Sprite.length, null);

    // print('Draw Line');
    for (int x = 0; x < LCD_WIDTH; ++x)
    {
      _setBackgroundColorID(x);
      _setWindowColorID(x);
    }
    _setSpriteColor();
    _updateScreenBuffer();
    return ;
  }

  void _setBackgroundColorID(int x) {
    // print('Background');
    if (!this.memr.rLCDC.isBackgroundDisplayEnabled)
      return ;
    final int posY = (this.memr.LY + this.memr.SCY) & 0xFF;
    final int posX =  (x + this.memr.SCX) & 0xFF;
    final int tileY = posY ~/ 8;
    final int tileX = posX ~/ 8;
    final int tileIDAddress = _getTileIDAddress(tileX, tileY, this.memr.rLCDC.tileMapID_BG);
    
    final int tileID = this.videoRam.pull8_unsafe(tileIDAddress);
    final int tileAddress = _getTileAddress(tileID, this.memr.rLCDC.tileDataID);
    final int relativeY = posY % 8;
    final int relativeX = posX % 8;
    final int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
    final int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
    final int colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
    final int colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
    _colorIDs_BG[x] = colorId_l | colorId_h;
    return ;
  }

  void _setWindowColorID(int x) {
    // print('Window');
    if (!this.memr.rLCDC.isWindowDisplayEnabled)
      return ;
    final int posY = this.memr.LY - this.memr.WY;
    if (posY < 0 || posY >= LCD_HEIGHT)
      return ;
    final int posX =  x - (this.memr.WX - 7);
    if (posX < 0 || posX >= LCD_WIDTH)
      return ;
    final int tileY = posY ~/ 8;
    final int tileX = posX ~/ 8;
    final int tileIDAddress = _getTileIDAddress(tileX, tileY, this.memr.rLCDC.tileMapID_WIN);
    
    final int tileID = this.videoRam.pull8_unsafe(tileIDAddress);
    final int tileAddress = _getTileAddress(tileID, this.memr.rLCDC.tileDataID);
    final int relativeY = posY % 8;
    final int relativeX = posX % 8;
    final int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
    final int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
    final int colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
    final int colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
    _colorIDs_BG[x] = colorId_l | colorId_h;
    return ;
  }

  void _setSpriteColor() {
    if (!this.memr.rLCDC.isSpriteDisplayEnabled)
      return ;
    _zBuffer.fillRange(0, _zBuffer.length, -1);

    final int sizeY = this.memr.rLCDC.spriteSize;

    for (int spriteno = 0; spriteno < 40; ++spriteno) {
      int spriteOffset = 0xFE00 + spriteno * 4;
      int posY = this.tr_pull8(spriteOffset) - 16;
      int relativeY = this.memr.LY - posY;
      if (relativeY < 0 || relativeY >= sizeY)
        continue ;

      int info = this.tr_pull8(spriteOffset + 3);
      bool priorityIsBG = (info >> 7) & 0x1 == 1;
      bool flipY = (info >> 6) & 0x1 == 1;
      bool flipX = (info >> 5) & 0x1 == 1;
      int OBP = ((info >> 4) & 0x1 == 0) ? this.memr.OBP0 : this.memr.OBP1;

      if (flipY)
        relativeY = sizeY - 1 - relativeY;

      int tileID = this.tr_pull8(spriteOffset + 2);
      /* tile address should use sizeY ? TO BE CHECKED */
      int tileAddress = 0x8000 + tileID * 16;
      int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
      int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
      int posX = this.tr_pull8(spriteOffset + 1) - 8;

      for (int relativeX = 0; relativeX < 8; ++relativeX) {
        int x = posX + relativeX;
        if (x < 0)
          continue ;
        if (x >= LCD_WIDTH)
          break ;

        /* Not sure about BG transparency here; TO BE CHECKED */
        if (priorityIsBG && _colorIDs_BG[x] != 0 &&_colorIDs_BG[x] != null)
          continue ;

        if (_zBuffer[x] >= 0)
          continue ;

        int colorId_l;
        int colorId_h;
        if (flipX)
        {
          colorId_l = (tileRow_l >> relativeX) & 0x1 == 1 ? 0x1 : 0x0;
          colorId_h = (tileRow_h >> relativeX) & 0x1 == 1 ? 0x2 : 0x0;
        }
        else
        {
          colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
          colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
        }

        int colorID = colorId_l | colorId_h;
        if (colorID == 0)
          continue;
        _colors_Sprite[x] = _getColor(colorID, OBP);
        _zBuffer[x] = spriteno;
      }
    }
  }

  void _updateScreenBuffer() {
    assert(_colorIDs_BG.length == LCD_WIDTH, 'Failure');
    assert(_colors_Sprite.length == LCD_WIDTH, 'Failure');
    final int BGP = this.memr.BGP;
    final int pixelStart = this.memr.LY * LCD_WIDTH;
    for (int x = 0; x < LCD_WIDTH; ++x)
    {
      if (_colors_Sprite[x] != null)
        _screenBuffer[pixelStart + x] = _colors_Sprite[x];
      else
        _screenBuffer[pixelStart + x] = _getColor(_colorIDs_BG[x], BGP);
    }
    return ;
  }

 /************************************************/ 
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


}
