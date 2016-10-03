// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphics.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/03 18:24:37 by jsaglio          ###   ########.fr       //
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

  GRegisterCurrentInfo();

  void init(Data.Ram tr) {
    this.LCDC = tr.pull8_unsafe(g_memRegInfos[MemReg.LCDC.index].address);
    this.STAT = tr.pull8_unsafe(g_memRegInfos[MemReg.STAT.index].address);
    this.LYC = tr.pull8_unsafe(g_memRegInfos[MemReg.LYC.index].address);
    this.LY = tr.pull8_unsafe(g_memRegInfos[MemReg.LY.index].address);
    this.SCY = tr.pull8_unsafe(g_memRegInfos[MemReg.SCY.index].address);
    this.SCX = tr.pull8_unsafe(g_memRegInfos[MemReg.SCX.index].address);
    this.WY = tr.pull8_unsafe(g_memRegInfos[MemReg.WY.index].address);
    this.WX = tr.pull8_unsafe(g_memRegInfos[MemReg.WX.index].address);
    this.BGP = tr.pull8_unsafe(g_memRegInfos[MemReg.BGP.index].address);
    return ;
  }

  bool get isLCDEnabled => (this.LCDC & (1 << 7) != 0);
  GraphicMode get mode => GraphicMode.values[this.STAT & 0x3];
  bool isInterruptMonitored(int intID) => (this.STAT & (1 << intID) != 0);

  bool get isWindowDisplayEnabled => (this.LCDC & (1 << 5) != 0);
  bool get isSpriteDisplayEnabled => (this.LCDC & (1 << 2) != 0);
  bool get isBackgroundDisplayEnabled => (this.LCDC & (1 << 0) != 0);
  int  get tileMapAddress_BG => (this.LCDC & (1 << 3) == 0) ? 0x9800 : 0x9C00;
  int  get tileMapAddress_WIN => (this.LCDC & (1 << 6) == 0) ? 0x9800 : 0x9C00;

  int getTileAddress(int tileID) {
    assert(tileID & ~0xFF == 0, 'Invalid tileID');
    if (this.LCDC & (1 << 4) == 0)
      return 0x8800 + tileID.toSigned(2) * 16;
    else
      return 0x8000 + tileID * 16;
  }

  Color getColor(int colorID) {
    assert(colorID & ~0x3 == 0, 'Invalid colorID');
    switch (colorID) {
      case (0) : return Color.values[(this.BGP >> 0) & 0x3];
      case (1) : return Color.values[(this.BGP >> 2) & 0x3];
      case (2) : return Color.values[(this.BGP >> 4) & 0x3];
      case (3) : return Color.values[(this.BGP >> 6) & 0x3];
      default : assert(false, 'getColor: switch failure');
    }
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

    if (!_current.isLCDEnabled)
    {
      _updated.LY = 0;
      _updated.mode = GraphicMode.VBLANK;
    }
    else
    {
      _updateGraphicMode(nbClock);
      if (_updated.drawLine)
        _drawLine();
      if (_updated.updateScreen)
        _updateScreen();
    }
    _updateGraphicRegisters();
    return ;
  }
  
  /* Private ******************************************************************/
  /* MUST UPDATE _updated_LY and _updated_mode, and request interrupt */
  void _updateGraphicMode(int nbClock) {
    bool interruptMonitored;

    _counterScanline += nbClock;
    if (_counterScanline >= NEWLINE_THRESHOLD)
    {
      _counterScanline = 0;
      _updateScanline();
    }
    else
    {
      _updated.LY = _current.LY;
      if (_counterScanline >= HBLANK_THRESHOLD)
      {
        _updated.mode = GraphicMode.HBLANK;
        interruptMonitored = _current.isInterruptMonitored(3);
      }
      else if (_counterScanline >= VRAM_THRESHOLD)
      {
        _updated.mode = GraphicMode.VRAM_ACCESS;
        interruptMonitored = false;
      }
      else
      {
        _updated.mode = GraphicMode.OAM_ACCESS;
        interruptMonitored = _current.isInterruptMonitored(5);
      }
      assert(_updated.LY != null, "LY: Condition Failure");
      assert(_updated.mode != null, "Mode: Condition Failure");
      assert(interruptMonitored != null, "interrupt: Condition Failure");

      /* FOR DEBUG */
      // print('''
      //   counterScanline: $_counterScanline
      //   Current mode: ${_current_mode.toString()}
      //   Update mode: ${_updated_mode.toString()}
      //   ''');

      if (interruptMonitored && (_updated.mode != _current.mode))
        this.requestInterrupt(InterruptType.LCDStat);
    }
    return ;
  }

  /* MUST UPDATE _updated_LY and _updated_mode, LCD Routine and interrupt */
  void _updateScanline() {
    final int incLY = _current.LY + 1;
    bool interruptMonitored;

    _updated.drawLine = true;
    if (incLY >= NEWFRAME_THRESHOLD)
    {
      _updated.LY = 0;
      _updated.mode = GraphicMode.OAM_ACCESS;
      _updated.updateScreen = true;
      interruptMonitored = _current.isInterruptMonitored(5);
    }
    else if (incLY >= VBLANK_THRESHOLD)
    {
      _updated.LY = incLY;
      _updated.mode = GraphicMode.VBLANK;
      interruptMonitored = _current.isInterruptMonitored(4);
    }
    else
    {
      _updated.LY = incLY;
      _updated.mode = GraphicMode.OAM_ACCESS;
      interruptMonitored = _current.isInterruptMonitored(5);
    }
    assert(_updated.LY != null, "LY: Condition Failure");
    assert(_updated.mode != null, "Mode: Condition Failure");
    assert(interruptMonitored != null, "interrupt: Condition Failure");

    /* FOR DEBUG */
    // print('''
    //   *** Update Line ***
    //   LY = $_updated_LY
    //   Current mode: ${_current_mode.toString()}
    //   Update mode: ${_updated_mode.toString()}
    //   ''');

    if (interruptMonitored && (_updated.mode != _current.mode))
        this.requestInterrupt(InterruptType.LCDStat);
    return ;
  }

  /* MUST trigger LYC interrupt and push new STAT/LY register */
  void _updateGraphicRegisters() {
    final int interrupt_bits = _current.STAT & 0xF8;
    final int mode_bits = _updated.mode.index;
    final int coincidence_bit = (_current.LYC == _updated.LY) ? (1 << 2) : 0;
    if (coincidence_bit != 0 && _current.isInterruptMonitored(6))
        this.requestInterrupt(InterruptType.LCDStat);
    _updated.STAT = coincidence_bit | mode_bits | interrupt_bits;
    this.tailRam.push8_unsafe(g_memRegInfos[MemReg.STAT.index].address
      , _updated.STAT);
    this.tailRam.push8_unsafe(g_memRegInfos[MemReg.LY.index].address
      , _updated.LY);
    return ;
  }

  /* Drawing functions ********************************************************/
  void _updateScreen() {
    Uint8List tmp;

    tmp = _buffer;
    _buffer = this.lcdScreen;
    this.lcdScreen = tmp;
    return ;
  }

  void _drawLine() {
    if (_current.LY < VBLANK_THRESHOLD)
    {
      for (int x = 0; x < LCD_WIDTH; ++x)
      {
        Color c = Color.White;
        if (_current.isBackgroundDisplayEnabled)
          c = _getBackgroundPixel(x);
        if (_current.isWindowDisplayEnabled)
          c = _getWindowPixel(x);
        if (_current.isSpriteDisplayEnabled)
          c = _getSpritePixel(x, c);
        _drawPixel(x, c);
      }
    }
    return ;
  }

  Color _getBackgroundPixel(int x) {
    final int posY = _current.SCY + _current.LY;
    final int tileY = posY ~/ 8;
    final int posX =  _current.SCX + x;
    final int tileX = posX ~/ 8;
    final int tileID = this.pull8(_current.tileMapAddress_BG + tileY * 32 + tileX);
    final int tileAddress = _current.getTileAddress(tileID);
    final int relativeY = posY % 8;
    final int tileRow = this.pull16(tileAddress + relativeY * 2);
    final int relativeX = posX % 8;
    final int colorId_l = (tileRow & (1 << (7 - relativeX)) == 0) ? 0x0 : 0x1;
    final int colorId_h = (tileRow & (1 << (15 - relativeX)) == 0) ? 0x0 : 0x2;
    return _current.getColor(colorId_l | colorId_h);
  }

  Color _getWindowPixel(int x) {
    return Color.White;
  }

  Color _getSpritePixel(int x, Color c) {
    return Color.White;
  }

  void _drawPixel(int x, Color c) {
    final int pixelOffset = (_current.LY * LCD_WIDTH + x) * 4;
    final List cList = _colorMap[c];
    _buffer[pixelOffset + 0] = cList[0];
    _buffer[pixelOffset + 1] = cList[1];
    _buffer[pixelOffset + 2] = cList[2];
    _buffer[pixelOffset + 3] = cList[3];
    return ;
  }

}
