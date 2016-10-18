// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_cart.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/04 18:25:33 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/18 17:48:01 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library platform_cart;

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

part 'platform_cart_parts.dart';

/* External events involving both emulator and cart system:
 *  Event        Emu req  Emu event             Action
 * *********************************************************************** *
 *  GBSocketDrop EmuStart Start                 _actionLoad
 *  ClickRestart EmuStart CrashedRestartError   _actionUnload(Opened|Closed)
 *  ClickRestart EmuStart EmulatingRestartError _actionUnload(Opened|Closed)
 *  DCBankDrop   EmuEject EmulatingEject        _actionUnload(Opened|Closed)
 *  DCBankDrop   EmuEject CrashedEject          _actionUnload(Opened|Closed)
 *  LSDelete     EmuEject EmulatingEject        _actionDeleteGameBoy
 *  LSDelete     EmuEject CrashedEject          _actionDeleteGameBoy
 */

class PlatformCart extends Object with _Actions implements _Super {

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;
  final PlatformEmulatorContacts _pec;
  final Emulator.Emulator _emu;

  HtmlCartClosable _openingOpt;

  // CONSTRUCTION *********************************************************** **
  PlatformCart(
      this._pcs, this._pde, this._pce, this._pdcs, this._pec, this._emu) {
    Ft.log('PlatformCart', 'contructor');

    _pde.onCartButtonClicked.forEach(_onCartButtonClicked);
    _pde.onCartDoneOpening.forEach(_onCartDoneOpening);
    _pde.onDropReceived
      .where((v) => v is CartBank)
      .map((v) => v as CartBank)
      .forEach(_onDropReceived);

    _emu.listener('Events')
      .where((map) => map['type'] is GameBoyEvent)
      .map((map) => map['type'] as GameBoyEvent)
      .forEach(_onGameBoyEvent);

    _pdcs.btnEject.onClick
      .forEach(_onEjectClick);
    _pdcs.btnRestart.onClick
      .forEach(_onRestartClick);
  }

  // PUBLIC ***************************************************************** **
  void newCart(DomCart that) {
    _actionNew(that);
    if (_openingOpt == null) {
      if (_pdcs.openedCart.isSome) {
        _pdcs.openedCart.v.hcc_startClose();
        _actionClose();
      }
      that.hcc_startOpen();
      _openingOpt = that;
    }
  }

  void deleteCart(DomCart that) {
    if (that == _pdcs.gbCart.v)
      _extractEject();
    else if (that == _pdcs.openedCart.v)
      _actionDeleteOpened();
    else {
      if (that == _openingOpt)
        that.hcc_abort();
      _actionDeleteClosed(that);
    }
  }

  // CALLBACKS ************************************************************** **
  void _onCartButtonClicked(HtmlCartClosable that) {
    assert(that != _pdcs.gbCart.v, "_onCartButtonClicked() that in gb");
    if (_openingOpt == null) {
      if (that == _pdcs.openedCart.v) {
        that.hcc_startClose();
        _actionClose();
      }
      else {
        that.hcc_startOpen();
        _openingOpt = that;
        if (_pdcs.openedCart.isSome) {
          _pdcs.openedCart.v.hcc_startClose();
          _actionClose();
        }
      }
    }
  }

  void _onCartDoneOpening(HtmlCartClosable that) {
    assert(that != _pdcs.gbCart.v, "_onCartDoneOpening() that in gb");
    assert(that == _openingOpt, "_onCartDoneOpening() that not opening");
    assert(_pdcs.openedCart.isNone, "_onCartDoneOpening() with one open");
    _openingOpt = null;
    _actionOpen(that);
  }

  void _onDropReceived(CartBank that) {
    assert(_pdcs.dragged.isSome, '_onDropReceived() with none dragged');
    if (that is DomGameBoySocket)
      _pec.requestStart(_pdcs.dragged.v as DomCart);
    else /* if (that is DomDetachedCartBank) */
      _extractEject();
  }

  void _onGameBoyEvent(GameBoyEvent ev) {
    if (ev.src is Absent && ev.dst is! Absent) {
      _pdcs.openedCart.v.hcc_hideButton();
      _actionLoad();
    }
    else if (ev.dst is Absent && ev.src is! Absent) {
      if (_pdcs.gbCart.v.data.life is Alive) {
        _pdcs.gbCart.v.hcc_showButton();
        if (_pdcs.openedCart.isSome || _openingOpt != null) {
          _pdcs.gbCart.v.hcc_startClose();
          _actionUnloadClosed();
        }
        else
          _actionUnloadOpened();
      }
      else /* if (_pdcs.gbCart.v.data.life is Dead) */
        _actionDeleteGameBoy();
    }
  }

  void _onEjectClick(_) {
    _pec.requestEject();
  }

  void _onRestartClick(_) {
    assert(_pdcs.gbCart.isSome, '_onRestartClick() with none in gb');
    _extractStart();
  }

  // PRIVATE **************************************************************** **
  void _extractStart() {
    final DomChip ramOpt = _pdcs.chipOfCartOpt(_pdcs.gbCart.v, Ram.v);

    if (ramOpt != null)
      _pec.requestRamExtraction(ramOpt.data.idbid);
    _pec.requestStart(_pdcs.gbCart.v as DomCart);
  }

  void _extractEject() {
    final DomChip ramOpt = _pdcs.chipOfCartOpt(_pdcs.gbCart.v, Ram.v);

    if (ramOpt != null)
      _pec.requestRamExtraction(ramOpt.data.idbid);
    _pec.requestEject();
  }

}