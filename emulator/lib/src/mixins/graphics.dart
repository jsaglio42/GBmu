// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphics.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/05 22:20:28 by jsaglio          ###   ########.fr       //
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

  void init(Data.Ram tr) {
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

  bool get isLCDEnabled => (this.LCDC & (1 << 7) != 0);
  GraphicMode get mode => GraphicMode.values[this.STAT & 0x3];
  bool isInterruptMonitored(GraphicMode g)
    => (this.STAT & (1 << (g.index + 3)) != 0);

  bool get isWindowDisplayEnabled => (this.LCDC & (1 << 5) != 0);
  bool get isSpriteDisplayEnabled => (this.LCDC & (1 << 1) != 0);
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

  Color getColorBG(int colorID) {
    assert(colorID & ~0x3 == 0, 'Invalid colorID');
    switch (colorID) {
      case (0) : return Color.values[(this.BGP >> 0) & 0x3];
      case (1) : return Color.values[(this.BGP >> 2) & 0x3];
      case (2) : return Color.values[(this.BGP >> 4) & 0x3];
      case (3) : return Color.values[(this.BGP >> 6) & 0x3];
      default : assert(false, 'getColor: switch failure');
    }
  }

  Color getColorOBJ(int colorID, int paletteID) {
    assert(colorID & ~0x3 == 0, 'Invalid colorID');
    final int OBP = (paletteID == 0) ? this.OBP0 : this.OBP1;
    switch (colorID) {
      case (1) : return Color.values[(OBP >> 2) & 0x3];
      case (2) : return Color.values[(OBP >> 4) & 0x3];
      case (3) : return Color.values[(OBP >> 6) & 0x3];
      default : return Color.values[(OBP >> 0) & 0x3];
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
      if (_current.STAT & (1 << 6) != 0)
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
    final int posX =  _current.SCX + x;
    final int tileY = posY ~/ 8;
    final int tileX = posX ~/ 8;
    final int tileID = this.videoRam.pull8_unsafe(_current.tileMapAddress_BG + tileY * 32 + tileX);
    final int tileAddress = _current.getTileAddress(tileID);
    final int relativeY = posY % 8;
    final int relativeX = posX % 8;
    final int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
    final int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
    final int colorId_l = (tileRow_l & (1 << (7 - relativeX)) == 0) ? 0x0 : 0x1;
    final int colorId_h = (tileRow_h & (1 << (7 - relativeX)) == 0) ? 0x0 : 0x2;
    return _current.getColorBG(colorId_l | colorId_h);
  }

  Color _getWindowPixel(int x) {
    final int posY = _current.LY - _current.WY;
    final int posX =  x - _current.WY;
    final int tileY = posY ~/ 8;
    final int tileX = posX ~/ 8;
    final int tileID = this.videoRam.pull8_unsafe(_current.tileMapAddress_WIN + tileY * 32 + tileX);
    final int tileAddress = _current.getTileAddress(tileID);
    final int relativeY = posY % 8;
    final int relativeX = posX % 8;
    final int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
    final int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
    final int colorId_l = (tileRow_l & (1 << (7 - relativeX)) == 0) ? 0x0 : 0x1;
    final int colorId_h = (tileRow_h & (1 << (7 - relativeX)) == 0) ? 0x0 : 0x2;
    // return _current.getColor(colorId_l | colorId_h);
    return Color.Black;
  }

  Color _getSpritePixel(int x, Color c) {
    final int sizeY = (_current.LCDC & (1 << 2) == 0) ? 8 : 16;
    for (int spriteno = 0; spriteno < 40; ++spriteno) {
      int spriteOffset = 0xFE00 + spriteno * 4;
      int info = this.tailRam.pull8_unsafe(spriteOffset + 3);
      // bool aboveBG = (info & (1 << 7)) == 0;
      // if (!aboveBG && c != Color.White)
        // continue ;
      int posY = this.tailRam.pull8_unsafe(spriteOffset);
      int relativeY = _current.LY - posY;
      if (relativeY < 0 || relativeY >= sizeY)
        continue ;
      bool flipY = (info & (1 << 6)) == 1;
      if (flipY)
        relativeY = sizeY - 1 - relativeY;
      int posX = this.tailRam.pull8_unsafe(spriteOffset + 1);
      int relativeX = x - posX;
      if (relativeX < 0 || relativeX >= 8)
        continue ;
      bool flipX = (info & (1 << 5)) == 1;
      if (flipX)
        relativeX = 7 - relativeX;
      print('lol');
      int tileID = this.tailRam.pull8_unsafe(spriteOffset + 2);
      int tileAddress = 0x8000 + tileID * 16;
      int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
      int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
      int colorId_l = (tileRow_l & (1 << (7 - relativeX)) == 0) ? 0x0 : 0x1;
      int colorId_h = (tileRow_h & (1 << (7 - relativeX)) == 0) ? 0x0 : 0x2;
      int OBP = (info >> 4) & 0x1;
      Color col = _current.getColorOBJ(colorId_l | colorId_h, OBP);
      if (col != Color.White)
        return c;
      }
    return c;
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







// void Emulator::RenderSprites( ) 
// {
//    bool use8x16 = false ;
//    if (TestBit(lcdControl,2))
//      use8x16 = true ;

//    for (int sprite = 0 ; sprite < 40; sprite++)
//    { 
//      // sprite occupies 4 bytes in the sprite attributes table
//      BYTE index = sprite*4 ; 
//      BYTE yPos = ReadMemory(0xFE00+index) - 16;
//      BYTE xPos = ReadMemory(0xFE00+index+1)-8;
//      BYTE tileLocation = ReadMemory(0xFE00+index+2) ;
//      BYTE attributes = ReadMemory(0xFE00+index+3) ;

//      bool yFlip = TestBit(attributes,6) ;
//      bool xFlip = TestBit(attributes,5) ;

//      int scanline = ReadMemory(0xFF44);

//      int ysize = 8; 
//      if (use8x16)
//        ysize = 16;

//      // does this sprite intercept with the scanline?
//      if ((scanline >= yPos) && (scanline < (yPos+ysize)))
//      {
//        int line = scanline - yPos ;

//        // read the sprite in backwards in the y axis
//        if (yFlip)
//        {
//          line -= ysize ;
//          line *= -1 ;
//        }

//        line *= 2; // same as for tiles
//        WORD dataAddress = (0x8000 + (tileLocation * 16)) + line ; 
//        BYTE data1 = ReadMemory( dataAddress ) ;
//        BYTE data2 = ReadMemory( dataAddress +1 ) ;

//        // its easier to read in from right to left as pixel 0 is 
//        // bit 7 in the colour data, pixel 1 is bit 6 etc...
//        for (int tilePixel = 7; tilePixel >= 0; tilePixel--)
//        { 
//          int colourbit = tilePixel ;
//          // read the sprite in backwards for the x axis 
//          if (xFlip) 
//          {
//            colourbit -= 7 ;
//            colourbit *= -1 ;
//          }

//          // the rest is the same as for tiles
//          int colourNum = BitGetVal(data2,colourbit) ;
//          colourNum <<= 1;
//          colourNum |= BitGetVal(data1,colourbit) ;

//          WORD colourAddress = TestBit(attributes,4)?0xFF49:0xFF48 ;
//          COLOUR col=GetColour(colourNum, colourAddress ) ;

//          // white is transparent for sprites.
//          if (col == WHITE)
//            continue ;

//          int red = 0;
//          int green = 0;
//          int blue = 0;

//          switch(col)
//          {
//            case WHITE: red =255;green=255;blue=255;break ;
//            case LIGHT_GRAY:red =0xCC;green=0xCC ;blue=0xCC;break ;
//            case DARK_GRAY:red=0x77;green=0x77;blue=0x77;break ;
//          }

//          int xPix = 0 - tilePixel ;
//          xPix += 7 ;

//          int pixel = xPos+xPix ;

//          // sanity check
//          if ((scanline<0)||(scanline>143)||(pixel<0)||(pixel>159))
//          {
//            continue ;
//          }

//          m_ScreenData[pixel][scanline][0] = red ;
//          m_ScreenData[pixel][scanline][1] = green ;
//          m_ScreenData[pixel][scanline][2] = blue ;
//        }
//      }
//    }
// }
