// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gameboycolor.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/28 18:56:33 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import "package:emulator/src/mixins/gameboy.dart" as GB;
import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;

import "package:emulator/src/GameBoyColor/internalrammanager.dart" as Iram;
import "package:emulator/src/GameBoyColor/videorammanager.dart" as Vram;
import "package:emulator/src/GameBoyColor/tailrammanager.dart" as Tram;
import "package:emulator/src/GameBoyColor/graphicdisplay.dart" as GDisplay;

class GameBoyColor extends GB.GameBoy
  with Iram.InternalRamManager
  , Vram.VideoRamManager
  , Tram.TailRamManager
  , GDisplay.GraphicDisplay
{

  /* Constructor */
  GameBoyColor(Cartridge.ACartridge c)
  : super.internal(c) {
    _initColors();
  }

  /* API */
  int exec(int nbClock) {
    int instructionDuration;
    int executedClocks = 0;
    while(executedClocks < nbClock)
    {
      instructionDuration = this.executeInstruction();
      this.updateTimers(instructionDuration);
      _updateGraphics(instructionDuration);
      executedClocks += instructionDuration;
      this.handleInterrupts();

      if (this.hardbreak)
        break ;
    }
    return (executedClocks);
  }

  /* Private */
  int _updateGraphics(int instructionDuration) {
    if (this.memr.rLCDC.isLCDEnabled)
    {
      this.lcd.resetDrawingInfo();
      this.updateGraphicMode(instructionDuration);
      this.updateDisplay();
    }
  }

  void _initColors() {
    /* Palette 0 - Grey */
    this.palette.setColor(0, 0, 0x1F + (0x1F << 5) + (0x1F << 10));
    this.palette.setColor(0, 1, 0x14 + (0x14 << 5) + (0x14 << 10));
    this.palette.setColor(0, 2, 0x0A + (0x0A << 5) + (0x0A << 10));
    this.palette.setColor(0, 3, 0x00 + (0x00 << 5) + (0x00 << 10));
    /* Palette 1 - Red */
    this.palette.setColor(1, 0, 0x1F);
    this.palette.setColor(1, 1, 0x14);
    this.palette.setColor(1, 2, 0x0A);
    this.palette.setColor(1, 3, 0x00);
    /* Palette 2 - Green */
    this.palette.setColor(2, 0, (0x1F << 5));
    this.palette.setColor(2, 1, (0x14 << 5));
    this.palette.setColor(2, 2, (0x0A << 5));
    this.palette.setColor(2, 3, (0x00 << 5));
    /* Palette 3 - Blue */
    this.palette.setColor(3, 0, (0x1F << 10));
    this.palette.setColor(3, 1, (0x14 << 10));
    this.palette.setColor(3, 2, (0x0A << 10));
    this.palette.setColor(3, 3, (0x00 << 10));
    return ;
  }

}
