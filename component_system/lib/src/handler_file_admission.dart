// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_file_admission.dart                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/09 17:33:31 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/14 15:28:57 by ngoguey          ###   ########.fr       //
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
import 'package:emulator/emulator.dart' as Emulator;
import 'package:emulator/constants.dart';

// import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class HandlerFileAdmission {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformComponentStorage _pcs;
  final PlatformDomComponentStorage _pdcs;

  final Html.Element _target = Html.querySelector('#cartsBody');
  int _docCount = 0;
  int _targetCount = 0;

  // CONTRUCTION ************************************************************ **
  HandlerFileAdmission(this._pde, this._pcs, this._pdcs) {
    Ft.log('HandlerFA', 'contructor');

    _pde.onFileDrag.forEach(_onFileDrag);
    _pde.onCartSystemHover.forEach(_onCartSystemHover);
    _pde.onCartSystemFilesDrop.forEach(_onCartSystemFilesDrop);
  }

  // CALLBACKS ************************************************************** **
  void _onFileDrag(bool b) {
    if (b)
      _target.classes.add('active');
    else
      _target.classes.remove('active');
  }

  void _onCartSystemHover(bool b) {
    if (_pdcs.fileDragged) {
      if (b)
        _target.classes.add('hover');
      else
        _target.classes.remove('hover');
    }
  }

  void _onCartSystemFilesDrop(List<Html.File> files) {
    _target.classes.remove('hover');
    files.forEach((Html.File f) {
      _processFile(f)
        .catchError((e, st){
          print(st);
          // TODO: show error in alerts
        });
    });
  }

  // PRIVATE **************************************************************** **
  Async.Future _processFile(Html.File f) async {
    Ft.log('HandlerFA', '_processFile', [f]);

    final Uint8List data = await _fileContent(f);

    Ft.log('HandlerFA', '_processFile#data-retrieved', ['len:${data?.length}']);
    if (f.name.endsWith(ROM_EXTENSION))
      await _pcs.newRom(new Emulator.Rom.ofFile(f.name, data));
    else if (f.name.endsWith(RAM_EXTENSION))
      await _pcs.newRam(new Emulator.Ram.ofFile(f.name, data));
    else if (f.name.endsWith(SS_EXTENSION))
      await _pcs.newSs(new Emulator.Ss.ofFile(f.name, data));
  }

  Async.Future<Uint8List> _fileContent(Html.File f) async {
    final reader = new Html.FileReader();

    reader.readAsArrayBuffer(f);
    await reader.onLoad.first;
    return reader.result;
  }

}
