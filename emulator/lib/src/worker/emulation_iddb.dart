// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_emulation_iddb.dart                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/19 18:19:04 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/22 19:27:21 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:js' as Js;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/src/events.dart';

import 'package:emulator/src/worker/worker.dart' as Worker;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/cartridge/cartridge.dart' as Cartridge;
import 'package:emulator/src/hardware/data.dart' as Data;
import 'package:emulator/src/hardware/save_state.dart' as Ss;
import 'package:emulator/src/emulator.dart' show RequestEmuStart;
import 'package:emulator/variants.dart' as V;

abstract class EmulationIddb implements Worker.AWorker {

  // PUBLIC ***************************************************************** **
  Async.Future<Gameboy.GameBoy> ei_assembleGameBoy(RequestEmuStart req) async
  {
    Cartridge.ACartridge c;

    // Ft.log('WorkerEmu', '_assembleGameBoy', [req]);

    final Idb.Database idb = await _futureDatabaseOfName(req.idb);
    // Ft.log('WorkerEmu', '_assembleGameBoy#got-idb', [idb]);

    final Data.Rom rom = new Data.Rom.unserialize(
        await _fieldOfKeys(idb, req.romStore, req.romKey));
    // Ft.log('WorkerEmu', '_assembleGameBoy#got-rom', [rom]);

    if (req.ramKeyOpt != null) {
      Data.Ram ram = new Data.Ram.unserialize(
          await _fieldOfKeys(idb, req.ramStore, req.ramKeyOpt));
      // Ft.log('WorkerEmu', '_assembleGameBoy#got-ram', [ram]);
      c = new Cartridge.ACartridge(rom, optionalRam: ram);
    }
    else
      c = new Cartridge.ACartridge(rom);
    // Ft.log('WorkerEmu', '_assembleGameBoy#got-cartridge', [c]);

    final Gameboy.GameBoy gb = new Gameboy.GameBoy(c);
    // Ft.log('WorkerEmu', '_assembleGameBoy#got-gb', [gb]);

    return gb;
  }

  Async.Future ei_extractRam(EventIdb ev) async {
    assert(this.gbMode != V.Absent, "_onExtractRamReq with no gameboy");

    final c = this.gbOpt.c.ram.rawData;
    final Idb.Database idb = await _futureDatabaseOfName(ev.idb);
    // Ft.log('WorkerEmu', '_onExtractRamReq#got-idb', [idb]);

    await _setDataOfField(idb, ev.store, ev.key, c);
    // Ft.log("WorkerEmu", '_onExtractRamReq#done');
  }

  Async.Future ei_extractSs(EventIdb ev) async {
    assert(this.gbMode != V.Absent, "_onExtractSsReq with no gameboy");

    final Ss.Ss c = new Ss.Ss.ofGameBoy(this.gbOpt);
    final Idb.Database idb = await _futureDatabaseOfName(ev.idb);

    print(c.serialize()['data']); //debug
    await _setDataOfField(idb, ev.store, ev.key, c.serialize()['data']);
  }

  Async.Future ei_installSs(EventIdb ev) async {
    assert(this.gbMode != V.Absent, "_onInstallSsReq with no gameboy");

    final Idb.Database idb = await _futureDatabaseOfName(ev.idb);
    final Ss.Ss ss = new Ss.Ss.unserialize(
        await _fieldOfKeys(idb, ev.store, ev.key));

    this.gbOpt.recUnserialize(ss.rawData);
    //TODO: Install ss into GameBoy
  }

  // PRIVATE **************************************************************** **
  Async.Future<Idb.Database> _futureDatabaseOfName(String name) {
    final idbf = Js.context['indexedDB'];
    final Async.Completer compl = new Async.Completer.sync();
    final req = idbf.callMethod('open', [name]);

    // Ft.log('WorkerEmu', '_futureDatabaseOfName', [name]);
    req['onsuccess'] = (ev){
      // Ft.log('WorkerEmu', '_onSuccess', [ev]);
      compl.complete(ev.target.result);
      new Async.Future.delayed(new Duration(milliseconds: 5), (){});
    };
    req['onerror'] = (ev){
      compl.completeError('Database error: ${ev.target.errorCode}');
      new Async.Future.delayed(new Duration(milliseconds: 5), (){});
    };
    return compl.future;
  }

  Async.Future<dynamic> _fieldOfKeys(
      Idb.Database idb, String storeName, int fieldKey) async {
    Idb.Transaction tra;
    dynamic serialized;

    tra = idb.transaction(storeName, 'readonly');

    await tra.objectStore(storeName)
    .openCursor(key: fieldKey)
    .take(1)
    .forEach((Idb.CursorWithValue cur) {
      serialized = cur.value;
    });
    return tra.completed.then((_) {
        if (serialized == null)
          throw new Exception('Missing $storeName#$fieldKey');
        else
          return serialized;
        });
  }

  Async.Future _setDataOfField(
      Idb.Database idb, String storeName, int fieldKey, dynamic data) async {
    Idb.Transaction tra;

    tra = idb.transaction(storeName, 'readwrite');
    await tra.objectStore(storeName)
    .openCursor(key: fieldKey)
    .take(1)
    .forEach((Idb.CursorWithValue cur) {
      final m = new Map.from(cur.value);

      m['data'] = data;
      cur.update(m);
    });
    return tra.completed;
  }

}
