// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphics.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/14 02:24:43 by jsaglio          ###   ########.fr       //
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
import "package:emulator/src/mixins/mmu.dart" as Mmu;

enum GraphicMode {
  HBLANK,
  VBLANK,
  OAM_ACCESS,
  VRAM_ACCESS
}

enum Color {
  White,
  LightGrey,
  DarkGrey,
  Black
}

final Map<Color, List<int>> _colorMap = new Map.unmodifiable({
  Color.White : [0xFF, 0xFF, 0xFF, 0xFF],
  Color.LightGrey : [0xAA, 0xAA, 0xAA, 0xFF],
  Color.DarkGrey : [0x55, 0x55, 0x55, 0x55],
  Color.Black : [0x00, 0x00, 0x00, 0xFF]
});

/* Small classes used to save data/store info *********************************/
class GRegisterCurrentInfo {

  int LCDC;
  int STAT;
  int LYC;
  int LY;
  int SCY;
  int SCX;
  int WY;
  int WX;
  int BGP;
  int OBP0;
  int OBP1;

  GRegisterCurrentInfo();

  void init(Data.GbRam tr) {
    this.LCDC = tr.pull8_unsafe(g_memRegInfos[MemReg.LCDC.index].address);
    this.STAT = tr.pull8_unsafe(g_memRegInfos[MemReg.STAT.index].address);
    this.LYC = tr.pull8_unsafe(g_memRegInfos[MemReg.LYC.index].address);
    this.LY = tr.pull8_unsafe(g_memRegInfos[MemReg.LY.index].address);
    this.SCY = tr.pull8_unsafe(g_memRegInfos[MemReg.SCY.index].address);
    this.SCX = tr.pull8_unsafe(g_memRegInfos[MemReg.SCX.index].address);
    this.WY = tr.pull8_unsafe(g_memRegInfos[MemReg.WY.index].address);
    this.WX = tr.pull8_unsafe(g_memRegInfos[MemReg.WX.index].address) - 7;
    this.BGP = tr.pull8_unsafe(g_memRegInfos[MemReg.BGP.index].address);
    this.OBP0 = tr.pull8_unsafe(g_memRegInfos[MemReg.OBP0.index].address);
    this.OBP1 = tr.pull8_unsafe(g_memRegInfos[MemReg.OBP1.index].address);
    return ;
  }

  bool get isLCDEnabled => (this.LCDC >> 7) & 0x1 == 1;
  bool get isWindowDisplayEnabled => (this.LCDC >> 5) & 0x1 == 1;
  bool get isSpriteDisplayEnabled => (this.LCDC >> 1) & 0x1 == 1;
  bool get isBackgroundDisplayEnabled => (this.LCDC >> 1) & 0x1 == 1;
  int  get tileMapAddress_BG => (this.LCDC >> 3) & 0x1 == 1 ? 0x9C00 : 0x9800;
  int  get tileMapAddress_WIN => (this.LCDC >> 6) & 0x1 == 1 ? 0x9C00 : 0x9800;

  GraphicMode get mode => GraphicMode.values[this.STAT & 0x3];

  bool isInterruptMonitored(GraphicMode g) {
    return (this.STAT >> (g.index + 3)) & 0x1 == 1;
  }

  int getTileAddress(int tileID) {
    assert(tileID & ~0xFF == 0, 'Invalid tileID');
    if ((this.LCDC >> 4) & 0x1 == 1)
      return 0x8000 + tileID * 16;
    else
      return 0x9000 + tileID.toSigned(8) * 16;
  }

  int getColor(int colorID, int palette) {
    if (colorID == null)
      return 0;
    else
      return (palette >> (2 * colorID)) & 0x3;
  }

}

/* Small classes used to save updated info ************************************/
class GRegisterUpdatedInfo {

    bool drawLine = false;
    bool updateScreen = false;

    int LY = null;
    GraphicMode mode = null;
    int STAT = null;

    GRegisterUpdatedInfo();

    void init() {
      this.drawLine = false;
      this.updateScreen = false;
      this.mode = null;
      this.STAT = null;
      this.LY = null;
      return ;
    }

}

/* Mixins that handle graphics ************************************************/
abstract class Graphics
  implements Hardware.Hardware
  , Mmu.Mmu
  , Interrupt.InterruptManager {

  /* Used for double buffering */
  Uint8List _buffer = new Uint8List(LCD_DATA_SIZE);

  /* Used to update LCDStatus */
  int _counterScanline = 0;
  GRegisterCurrentInfo _current = new GRegisterCurrentInfo();
  GRegisterUpdatedInfo _updated = new GRegisterUpdatedInfo();

  /* API **********************************************************************/
  void updateGraphics(int nbClock) {
    _current.init(this.tailRam);
    _updated.init();

    /* will need special routine when enabling */
    if (_current.isLCDEnabled)
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

  // to be implemented
  // void enableScreen(int nbClock) {
  //   _updated.LY = 0;
  //   _counterScanline = 0;
  //   _updated.mode = GraphicMode.OAM_ACCESS;
  // }

  /* Private ******************************************************************/
  void _updateGraphicMode(int nbClock) {
    // print('$_counterScanline : ${_current.mode.toString()}');
    _counterScanline += nbClock;
    switch (_current.mode)
    {
      case (GraphicMode.OAM_ACCESS) : _OAM_routine(); break;
      case (GraphicMode.VRAM_ACCESS) : _VRAM_routine(); break;
      case (GraphicMode.HBLANK) : ; _HBLANK_routine(); break;
      case (GraphicMode.VBLANK) : ; _VBLANK_routine(); break;
      default: assert (false, 'GraphicMode: switch failure');
    }
    assert(_updated.LY != null, "LY: Condition Failure");
    assert(_updated.mode != null, "Mode: Condition Failure");
  }

  /* Switch to VRAM_ACCESS or remain as is */
  void _OAM_routine() {
    if (_counterScanline >= CLOCK_PER_OAM_ACCESS)
    {
      _counterScanline -= CLOCK_PER_OAM_ACCESS;
      _updated.LY = _current.LY;
      _updated.mode = GraphicMode.VRAM_ACCESS;
    }
    else
    {
      _updated.LY = _current.LY;
      _updated.mode = _current.mode;
    }
  }

  /* Switch to HBLANK or remain as is */
  void _VRAM_routine() {
    if (_counterScanline >= CLOCK_PER_VRAM_ACCESS)
    {
      _counterScanline -= CLOCK_PER_VRAM_ACCESS;
      _updated.LY = _current.LY;
      _updated.mode = GraphicMode.HBLANK;
      if (_current.isInterruptMonitored(_updated.mode))
        this.requestInterrupt(InterruptType.LCDStat);
    }
    else
    {
      _updated.LY = _current.LY;
      _updated.mode = _current.mode;
    }
  }

  /* Switch to OAM_ACCESS/VBLANK or remain as is */
  void _HBLANK_routine() {
    if (_counterScanline >= CLOCK_PER_HBLANK)
    {
      _counterScanline -= CLOCK_PER_HBLANK;
      _updated.drawLine = true;
      _updated.LY = _current.LY + 1;
      if (_updated.LY < VBLANK_THRESHOLD)
        _updated.mode = GraphicMode.OAM_ACCESS;
      else
      {
        _updated.mode = GraphicMode.VBLANK;
        this.requestInterrupt(InterruptType.VBlank);
      }
      if (_current.isInterruptMonitored(_updated.mode))
        this.requestInterrupt(InterruptType.LCDStat);
    }
    else
    {
      _updated.LY = _current.LY;
      _updated.mode = _current.mode;
    }
  }

  /* Switch to OAM_ACCESS or remain as is */
  void _VBLANK_routine() {
    if (_counterScanline >= CLOCK_PER_LINE)
    {
      _counterScanline -= CLOCK_PER_LINE;
      final int incLY = _current.LY + 1;
      if (incLY >= FRAME_THRESHOLD)
      {
        _updated.updateScreen = true;
        _updated.LY = 0;
        _updated.mode = GraphicMode.OAM_ACCESS;
        if (_current.isInterruptMonitored(_updated.mode))
          this.requestInterrupt(InterruptType.LCDStat);
      }
      else
      {
        _updated.LY = incLY;
        _updated.mode = _current.mode;
      }
    }
    else
    {
      _updated.LY = _current.LY;
      _updated.mode = _current.mode;
    }
  }

  /* MUST trigger LYC interrupt and push new STAT/LY register */
  void _updateGraphicRegisters() {
    final int interrupt_bits = _current.STAT & 0xF8;
    final int mode_bits = _updated.mode.index;
    if (_current.LYC != _updated.LY)
      _updated.STAT = mode_bits | interrupt_bits;
    else
    {
      _updated.STAT = mode_bits | interrupt_bits | 0x4;
      if ((_current.STAT >> 6) & 0x1 == 1)
        this.requestInterrupt(InterruptType.LCDStat);
    }
    this.tailRam
      ..push8_unsafe(g_memRegInfos[MemReg.STAT.index].address, _updated.STAT)
      ..push8_unsafe(g_memRegInfos[MemReg.LY.index].address, _updated.LY);
    return ;
  }

  /* Drawing functions ********************************************************/
  void _updateScreen() {
    Uint8List tmp;

    // print('UpdateScreen');
    tmp = _buffer;
    _buffer = this.lcdScreen;
    this.lcdScreen = tmp;
    return ;
  }

  void _drawLine() {
    List<int> BGColorIDs = new List<int>.filled(LCD_WIDTH, null);
    List<int> SpriteColors = new List<int>.filled(LCD_WIDTH, null);

    // print('Draw Line');
    for (int x = 0; x < LCD_WIDTH; ++x)
    {
      _setBackgroundColorID(x, BGColorIDs);
      _setWindowColorID(x, BGColorIDs);
    }
    _setSpriteColor(BGColorIDs, SpriteColors);
    _updateScreenBuffer(BGColorIDs, SpriteColors);
    return ;
  }

  void _setBackgroundColorID(int x, List<int> BGColorIDs) {
    // print('Background');
    if (!_current.isBackgroundDisplayEnabled)
      return ;
    final int posY = (_current.LY + _current.SCY) & 0xFF;
    final int posX =  (x + _current.SCX) & 0xFF;
    final int tileY = posY ~/ 8;
    final int tileX = posX ~/ 8;
    final int tileID = this.videoRam.pull8_unsafe(_current.tileMapAddress_BG + tileY * 32 + tileX);

    final int tileAddress = _current.getTileAddress(tileID);

    final int relativeY = posY % 8;
    final int relativeX = posX % 8;
    final int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
    final int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
    final int colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
    final int colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
    BGColorIDs[x] = colorId_l | colorId_h;
    return ;
  }

  void _setWindowColorID(int x, List<int> BGColorIDs) {
    // print('Window');
    if (!_current.isWindowDisplayEnabled)
      return ;
    final int posY = _current.LY - _current.WY;
    if (posY < 0 || posY >= LCD_HEIGHT)
      return ;
    final int posX =  x - _current.WX;
    if (posX < 0 || posX >= LCD_WIDTH)
      return ;
    final int tileY = posY ~/ 8;
    final int tileX = posX ~/ 8;
    final int tileID = this.videoRam.pull8_unsafe(_current.tileMapAddress_WIN + tileY * 32 + tileX);

    final int tileAddress = _current.getTileAddress(tileID);

    final int relativeY = posY % 8;
    final int relativeX = posX % 8;
    final int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
    final int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
    final int colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
    final int colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
    BGColorIDs[x] = colorId_l | colorId_h;
    return ;
  }

  void _setSpriteColor(List<int> BGColorIDs, List<int> SpriteColors) {
    if (!_current.isSpriteDisplayEnabled)
      return ;
    final List<int> zbuffer = new List.filled(LCD_WIDTH, -1);

    final int sizeY = ((_current.LCDC >> 2) & 0x1 == 1) ? 16 : 8;

    for (int spriteno = 0; spriteno < 40; ++spriteno) {
      int spriteOffset = 0xFE00 + spriteno * 4;
      int posY = this.tailRam.pull8_unsafe(spriteOffset) - 16;
      int relativeY = _current.LY - posY;
      if (relativeY < 0 || relativeY >= sizeY)
        continue ;

      int info = this.tailRam.pull8_unsafe(spriteOffset + 3);
      bool priorityIsBG = (info >> 7) & 0x1 == 1;
      bool flipY = (info >> 6) & 0x1 == 1;
      bool flipX = (info >> 5) & 0x1 == 1;
      int OBP = ((info >> 4) & 0x1 == 0) ? _current.OBP0 : _current.OBP1;

      if (flipY)
        relativeY = sizeY - 1 - relativeY;

      int tileID = this.tailRam.pull8_unsafe(spriteOffset + 2);
      /* tile address should use sizeY ? TO BE CHECKED */
      int tileAddress = 0x8000 + tileID * 16;
      int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
      int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
      int posX = this.tailRam.pull8_unsafe(spriteOffset + 1) - 8;

      for (int relativeX = 0; relativeX < 8; ++relativeX) {
        int x = posX + relativeX;
        if (x < 0)
          continue ;
        if (x >= LCD_WIDTH)
          break ;

        /* Not sure about BG transparency here; TO BE CHECKED */
        if (priorityIsBG && BGColorIDs[x] != 0 && BGColorIDs[x] != null)
          continue ;

        if (zbuffer[x] >= 0)
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
        SpriteColors[x] = _current.getColor(colorID, OBP);
        zbuffer[x] = spriteno;
      }
    }
  }

  void _updateScreenBuffer(List<int> BGColorIDs, List<int> SpriteColors) {
    assert(BGColorIDs.length == LCD_WIDTH, 'Failure');
    assert(SpriteColors.length == LCD_WIDTH, 'Failure');
    int BGP = _current.BGP;
    for (int x = 0; x < LCD_WIDTH; ++x)
    {
      Color c;
      int pixelOffset = (_current.LY * LCD_WIDTH + x) * 4;
      if (SpriteColors[x] != null)
        c = Color.values[SpriteColors[x]];
      else
        c = Color.values[_current.getColor(BGColorIDs[x], BGP)];
      List cList = _colorMap[c];
      _buffer[pixelOffset + 0] = cList[0];
      _buffer[pixelOffset + 1] = cList[1];
      _buffer[pixelOffset + 2] = cList[2];
      _buffer[pixelOffset + 3] = cList[3];
    }
    return ;
  }

}
