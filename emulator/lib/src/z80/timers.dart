// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   z80.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 10:19:54 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";

import "package:emulator/src/memory/mmu.dart" as Mmu;

class Timers {

  final MMU.Mmu _mmu;

  int _clockTotal;
  int _counterTIMA;
  int _counterDIV;

  /*
  ** Constructors **************************************************************
  */

  Timers(Mmu.Mmu m)
    : _mmu = m
    , _clockTotal = 0
    , _counterTIMA = 0
    , _counterDIV = 0;

  Timers.clone(Timers src)
    : _mmu = src._mmu,
    , _clockTotal = src._clockTotal
    , _counterTIMA = src._counterTIMA
    , _counterDIV = src._counterDIV;

  /*
  ** API ***********************************************************************
  */

  int get clockCount => _clockTotal;

  void reset() {
    _clockTotal = 0;
    _counterTIMA = 0;
    _counterDIV = 0;
    return ;
  }

  void update(int nbClock) {
    _clockTotal += nbClock;
    _updateDIV(nbClock);
    _updateTIMA(nbClock);
    return ;
  }

  /*
  ** Private *******************************************************************
  */

  void _updateDIV(int nbClock) {
    _counterDIV -= nbClock;
    if (_counterDIV < 0)
    {
      _counterDIV = 256;
      final int div = _mmu.pullMemReg(MemReg.DIV);
      // _mmu.setDIV((div + 1) & 0xFF);
    }
    return ;
  }

  void _updateTIMA(int nbClock) {
    final int TAC = _mmu.pullMemReg(MemReg.TAC);
    if (TAC & (0x1 << 2) != 0) {
      _counterTIMA -= nbClock;
      if (_counterTIMA < 0)
      {
        switch(TAC & 0x3)
        {
          case (0): _counterTIMA = 1024; break;
          case (1): _counterTIMA = 16; break;
          case (2): _counterTIMA = 64; break;
          case (3): _counterTIMA = 256; break;
          default : assert(false, '_updateTIMA: switch failure')
        }
        final int TMA = _mmu.pullMemReg(MemRef.TIMA);
        _mmu.pushMemReg(MemReg.TIMA, TMA);
        // Request INTERRUPT
      }

    }
    return ;
  }







}
