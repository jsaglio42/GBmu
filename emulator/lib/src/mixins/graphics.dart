// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphics.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/30 11:09:16 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/interruptmanager.dart" as Interrupt;
import "package:emulator/src/mixins/mmu.dart" as Mmu;

final int _addrLCDC = g_memRegInfos[MemReg.LCDC.index].address;
final int _addrSTAT = g_memRegInfos[MemReg.STAT.index].address;
final int _addrLY = g_memRegInfos[MemReg.LY.index].address;
final int _addrLYC = g_memRegInfos[MemReg.LYC.index].address;

enum GraphicMode {
  HBLANK,
  VBLANK,
  OAM_ACCESS,
  VRAM_ACCESS
}

abstract class Graphics
  implements Hardware.Hardware
  , Mmu.Mmu
  , Interrupt.InterruptManager {

  /* Used for double buffering */
  Uint8List _buffer = new Uint8List(LCD_DATA_SIZE);
  
  /* Used to update LCDStatus */
  int _counterScanline = 0;
  int _current_STAT;
  int _current_LYC;
  int _current_LY;
  GraphicMode _current_mode;
  
  int _updated_LY;
  GraphicMode _updated_mode;

  /* API **********************************************************************/
  void updateGraphics(int nbClock) {
    _updateCurrentStatus();
    // if (_current_STAT & (1 << 7) != 0) {
      _updateGraphicMode(nbClock);
      _updateLCDStatus();
    // }
    /* Not sure what to do, should probably trap in mmu */
    // else
    //   _resetScreen(); 
  }

  /* Private ******************************************************************/
  void _updateCurrentStatus() {
    _current_STAT = this.tailRam.pull8_unsafe(_addrSTAT);
    _current_LYC = this.tailRam.pull8_unsafe(_addrLYC);
    _current_LY = this.tailRam.pull8_unsafe(_addrLY);
    _current_mode = GraphicMode.values[_current_STAT & 0x3];
    _updated_LY = null;
    _updated_mode = null;
    return ;
  }

  /* MUST UPDATE _updated_LY and _updated_mode, and request interrupt */
  void _updateGraphicMode(int nbClock) {
    bool interruptMonitored;

    _counterScanline += nbClock;
    if (_counterScanline >= NEWLINE_THRESHOLD)
    {
      _counterScanline = 0;
      if (_current_LY < VBLANK_THRESHOLD)
        _drawLine();
      _updateScanline();
    }
    else
    {
      _updated_LY = _current_LY;
      if (_counterScanline >= HBLANK_THRESHOLD)
      {
        _updated_mode = GraphicMode.HBLANK;
        interruptMonitored = (_current_STAT & (1 << 3) != 0) ? true : false;
      }
      else if (_counterScanline >= VRAM_THRESHOLD)
      {
        _updated_mode = GraphicMode.VRAM_ACCESS;
        interruptMonitored = false;
      }
      else
      {
        _updated_mode = GraphicMode.OAM_ACCESS;
        interruptMonitored = (_current_STAT & (1 << 5) != 0) ? true : false;
      }
      assert(_updated_LY != null, "LY: Condition Failure");
      assert(_updated_mode != null, "Mode: Condition Failure");
      assert(interruptMonitored != null, "interrupt: Condition Failure");
      // print('''
      //   counterScanline: $_counterScanline
      //   Current mode: ${_current_mode.toString()}
      //   Update mode: ${_updated_mode.toString()}
      //   ''');
      if (interruptMonitored && (_current_mode != _updated_mode))
        this.requestInterrupt(InterruptType.LCDStat);
    }
    return ;
  }

  /* MUST UPDATE _updated_LY and _updated_mode, and request interrupt */
  /* MUST UPDATE LY register (in memory) */
  void _updateScanline() {
    bool interruptMonitored;

    final int incLY = _current_LY + 1;
    if (incLY >= NEWFRAME_THRESHOLD || incLY < VBLANK_THRESHOLD)
    {
      if (incLY >= NEWFRAME_THRESHOLD) {
        _updated_LY = 0;
        _updateScreen();
      }
      else
      {
        _updated_LY = incLY;
        _drawLine();
      }
      _updated_mode = GraphicMode.OAM_ACCESS;
      interruptMonitored = (_current_STAT & (1 << 5) != 0) ? true : false;
    }
    else {
      _updated_LY = incLY;
      _updated_mode = GraphicMode.VBLANK;
      interruptMonitored = (_current_STAT & (1 << 4) != 0) ? true : false;
    }
    assert(_updated_LY != null, "LY: Condition Failure");
    assert(_updated_mode != null, "Mode: Condition Failure");
    assert(interruptMonitored != null, "interrupt: Condition Failure");
    print('''
      *** Update Line ***
      LY = $_updated_LY
      Current mode: ${_current_mode.toString()}
      Update mode: ${_updated_mode.toString()}
      ''');
    if (interruptMonitored && (_current_mode != _updated_mode))
        this.requestInterrupt(InterruptType.LCDStat);
    this.tailRam.push8_unsafe(_addrLY, _updated_LY);
    return ;
  }

  /* MUST trigger LYC interrupt and push new STAT register */
  void _updateLCDStatus() {
    int coincidence_bit = 0;
    int mode_bits = _updated_mode.index;
    int interrupt_bits = _current_STAT & 0xF8;

    if (_current_LYC == _updated_LY)
    {
      coincidence_bit = (1 << 2);
      if (_current_STAT & (1 << 6) != 0)
        this.requestInterrupt(InterruptType.LCDStat);
    }
    final int updated_STAT = coincidence_bit | mode_bits | interrupt_bits;
    this.tailRam.push8_unsafe(_addrSTAT, updated_STAT);
    return ;
  }

  /* Swap the buffer and the LCD Screen */
  void _updateScreen() {
    print('**************************************** Update Screen');
    Uint8List tmp;
    tmp = _buffer;
    _buffer = this.lcdScreen;
    this.lcdScreen = tmp;
    return ;
  }

  /* This is for test only, should draw striped screen */
  void _drawLine(){
    int LY = this.tailRam.pull8_unsafe(_addrLY);
    List<int> colorlist;
    colorlist = (LY % 2 == 0) ? [0xFF, 0, 0, 0xFF] : [0, 0, 0xFF, 0xFF];
    for (int i = 0; i < LCD_WIDTH; ++i) {
      int pixelOffset = 4 * (LY * LCD_WIDTH + i);
      _buffer[pixelOffset + 0] = colorlist[0];
      _buffer[pixelOffset + 1] = colorlist[1];
      _buffer[pixelOffset + 2] = colorlist[2];
      _buffer[pixelOffset + 3] = colorlist[3];
    }
    return ;
  }

}
