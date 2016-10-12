// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_file_admission.dart                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/09 17:33:31 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/12 17:34:33 by ngoguey          ###   ########.fr       //
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
// import 'package:component_system/src/include_cdc.dart';

// http://stackoverflow.com/questions/3144881/how-do-i-detect-a-html5-drag-event-entering-and-leaving-the-window-like-gmail-d

class HandlerFileAdmission {

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;

  final Html.Element _target = Html.querySelector('#cartsBody');
  int _docCount = 0;
  int _targetCount = 0;

  // CONTRUCTION ************************************************************ **
  HandlerFileAdmission(this._pcs) {
    Ft.log('HandlerFA', 'contructor');

    Html.document.onDragEnter.forEach(_handleDocEnter);
    Html.document.onDragLeave.forEach(_handleDocLeave);
    Html.document.onDragOver.forEach(_handleDocOver);
    Html.document.onDrop.forEach(_handleDocDrop);

    _target.onDragEnter.forEach(_handleTargetEnter);
    _target.onDragLeave.forEach(_handleTargetLeave);
  }

  // CALLBACKS ************************************************************** **
  void _handleDocEnter(Html.MouseEvent ev) {
    if (_docCount == 0)
      _target.classes.add('active');
    _docCount++;
  }

  void _handleDocLeave(Html.MouseEvent ev) {
    _docCount--;
    if (_docCount == 0)
      _target.classes.remove('active');
  }

  void _handleDocOver(Html.MouseEvent ev) {
    ev.stopPropagation();
    ev.preventDefault();
  }

  void _handleDocDrop(Html.MouseEvent ev) {
    ev.stopPropagation();
    ev.preventDefault();
    _target.classes.remove('active');
    _target.classes.remove('hover');
    if (_targetCount > 0) {
      if (ev.dataTransfer.types.contains('Files')) {
        ev.dataTransfer.files.forEach((Html.File f) {
          _processFile(f)
            .catchError((e, st){
              print(st);
              // TODO: show error in alerts
            });
        });
      }
      else {
        // TODO: show error in alerts
      }
    }
    _targetCount = 0;
    _docCount = 0;
  }

  void _handleTargetEnter(Html.MouseEvent ev) {
    if (_targetCount == 0)
      _target.classes.add('hover');
    _targetCount++;
  }

  void _handleTargetLeave(Html.MouseEvent ev) {
    _targetCount--;
    if (_targetCount == 0)
      _target.classes.remove('hover');
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
