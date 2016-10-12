// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_emulator_communication.dart                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/12 17:33:50 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/12 17:50:21 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class HandlerEmulatorCommunication {

  // ATTRIBUTES ************************************************************* **
  final Emulator.Emulator _emu;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  // CONTRUCTION ************************************************************ **
  HandlerEmulatorCommunication(this._emu, this._pce, this._pdcs) {
    Ft.log('HandlerEC', 'contructor');

    _pce.onCartEvent
      .where((CartEvent<DomCart> ev) => ev.isGbChange)
      .forEach(_onGbCartEvent);

  }

  // CALLBACKS ************************************************************** **
  void _onGbCartEvent(CartEvent<DomCart> ev) {
    final LsRom dataRom = ev.cart.data;
    LsRam dataRamOpt;

    if (ev.dst is GameBoy) {
      dataRamOpt = _pdcs.chipOfCartOpt(ev.cart, Ram.v)?.data;
      _emu.send('EmulationStart',
          new Emulator.RequestEmuStart(
              idb:'GBmu_db',
              romStore: Rom.v.toString(),
              ramStore: Ram.v.toString(),
              romKey: dataRom.idbid,
              ramKeyOpt: dataRamOpt?.idbid));
    }
    else
      _emu.send('EmulationEject', 42);
  }


  // PRIVATE **************************************************************** **

}