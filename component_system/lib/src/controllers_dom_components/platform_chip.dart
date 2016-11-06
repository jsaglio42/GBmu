// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_chip.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/05 17:16:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/06 18:45:33 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library platform_chip;

import 'dart:js' as Js;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

part 'platform_chip_parts.dart';

class PlatformChip extends Object with _Actions implements _Super
{

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;
  final PlatformEmulatorContacts _pec;

  // CONSTRUCTION *********************************************************** **
  PlatformChip(this._pcs, this._pde, this._pce, this._pdcs, this._pec) {
    Ft.log('PlatformChip', 'contructor');

    _pde.onDropReceived
      .where((v) => v is ChipBank)
      .map((v) => v as ChipBank)
      .forEach(_onDropReceived);
    _pdcs.btnExtractRam.onClick
      .forEach(_onExtractRamClick);
    _pde.onRequestInstallSaveState.forEach(_onRequestInstallSaveState);
    _pde.onRequestExtractSaveState.forEach(_onRequestExtractSaveState);
    _pde.onRequestSaveToFile.forEach(_onRequestSaveToFile);
    _pde.onRequestDetach.forEach(_onRequestDetach);
    _pde.onRequestDuplicate.forEach(_onRequestDuplicate);
    _pde.onRequestDelete
      .where((DomComponent c) => c is DomChip)
      .map((c) => c as DomChip)
      .forEach(_onRequestDelete);
  }

  // PUBLIC ***************************************************************** **
  void newChip(DomChip that) {
    final LsChip data = that.data as LsChip;

    if (!data.isBound)
      _actionNewDetached(that);
    else
      _actionNewAttached(that);
  }

  void deleteChip(DomChip that) {
    final LsChip data = that.data as LsChip;

    if (!data.isBound)
      _actionDeleteDetached(that);
    else
      _actionDeleteAttached(that);
  }

  void updateChip(DomChip that, Update<LsEntry> u) {
    final LsChip oldDat = u.oldValue;
    final LsChip newDat = u.newValue;

    that.setData(newDat);
    if (oldDat.isBound && newDat.isBound)
      _actionMoveAttach(
          that, _pdcs.componentOfUid(oldDat.romUid.v),
          _pdcs.componentOfUid(newDat.romUid.v));
    else if (oldDat.isBound && !newDat.isBound)
      _actionDetach(that, _pdcs.componentOfUid(oldDat.romUid.v));
    else if (!oldDat.isBound && newDat.isBound)
      _actionAttach(that, _pdcs.componentOfUid(newDat.romUid.v));
    else
      assert(false, 'updateChip#unreachable');
  }

  void extractSs(int slot) {
    DomChip ss;

    if (_pdcs.gbCart.isSome) {
      ss = _pdcs.chipOfCartOpt(_pdcs.gbCart.v, Ss.v, slot);
      if (ss != null)
        _extractSs(ss.data);
      else
        _extractNewSs(slot);
    }
  }

  void installSs(int slot) {
    DomChip ss;

    if (_pdcs.gbCart.isSome) {
      ss = _pdcs.chipOfCartOpt(_pdcs.gbCart.v, Ss.v, slot);
      if (ss != null)
        _installSs(ss.data);
    }
  }

  // CALLBACKS ************************************************************** **

  // The almighty function that has the view on:
  //   The chip-socket, the cart, and the dragged chip.
  void _onDropReceived(ChipBank that) {
    DomCart cart;
    DomChip chip;
    LsChip chdata;

    assert(_pdcs.dragged.isSome, '_onDropReceived() with none dragged');
    chip = _pdcs.dragged.v;
    chdata = chip.data as LsChip;
    if (that is DomDetachedChipBank)
      _pcs.unbind(chdata);
    else {
      cart = _pdcs.cartOfSocket(that as DomChipSocket);
      if (chdata.type is Ram)
        _pcs.bindRam(chdata, cart.data);
      else
        _pcs.bindSs(chdata, cart.data, cart.ssSocketIndex(that));
    }
  }

  Async.Future _onExtractRamClick(_) async {
    assert(_pdcs.gbCart.isSome, '_onExtractRamClick() with none in gb');

    final LsRom romData = _pdcs.gbCart.v.data;
    final Emulator.Ram ram =
      new Emulator.Ram.emptyDetail(romData.fileName, romData.ramSize);
    final LsRam unsafeRamData = await _pcs.newRamBound(ram, romData);

    _pec.requestRamExtraction(unsafeRamData.idbid);
  }

  void _onRequestInstallSaveState(DomChip c) {
    Ft.log('PlatformChip', '_onRequestInstallSaveState', [c]);
    _installSs(c.data as LsSs);
  }

  void _onRequestExtractSaveState(DomChip c) {
    Ft.log('PlatformChip', '_onRequestExtractSaveState', [c]);
    _extractSs(c.data as LsSs);
  }

  Async.Future _onRequestSaveToFile(DomChip c) async {
    final Html.AnchorElement a = new Html.AnchorElement();
    var data;

    Ft.log('PlatformChip', '_onRequestSaveToFile', [c]);
    if (c.data.type is Ram)
      data = await _pcs.getRawData(c.data);
    else
      data = JSON.encode(await _pcs.getRawData(c.data));
    a.href = Html.Url.createObjectUrl(
        new Html.Blob([data], 'application/octet-stream'));
    a.download = c.data.fileName;
    a.click();
  }

  void _onRequestDetach(DomChip c) {
    Ft.log('PlatformChip', '_onRequestDetach', [c]);
    _pcs.unbind(c.data);
  }

  void _onRequestDuplicate(DomChip c) {
    Ft.log('PlatformChip', '_onRequestDuplicate', [c]);
    _pcs.duplicate(c.data);
  }

  void _onRequestDelete(DomChip c) {
    Ft.log('PlatformChip', '_onRequestDelete', [c]);
    _pcs.delete(c.data);
  }

  // PRIVATE **************************************************************** **
  void _installSs(LsSs ss) {
    Ft.log('PlatformChip', '_installSs', [ss]);
    _pec.requestSsInstallation(ss.idbid);
  }

  void _extractSs(LsSs ss) {
    Ft.log('PlatformChip', '_extractSs', [ss]);
    _pec.requestSsExtraction(ss.idbid);
  }

  Async.Future _extractNewSs(int slot) async {
    Ft.log('PlatformChip', '_extractNewSs', [slot]);

    final LsRom romData = _pdcs.gbCart.v.data;
    final Emulator.Ss ss =
      new Emulator.Ss.emptyDetail(romData.fileName, romData.globalChecksum);
    final LsSs unsafeSsData = await _pcs.newSsBound(ss, slot, romData);

    _pec.requestSsExtraction(unsafeSsData.idbid);
   }

}