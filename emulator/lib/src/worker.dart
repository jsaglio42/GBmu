// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/26 12:00:15 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/src/memory/rom.dart' as Rom;
import 'package:emulator/src/memory/ram.dart' as Ram;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;
import 'package:emulator/src/memory/cartmbc0.dart' as Cartmbc0;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker_emulation.dart' as Workeremulation;
import 'package:emulator/src/worker_debug.dart' as Workerdebug;

DateTime now() => new DateTime.now();

/** Abstract Worker */
/** Variables should not be `private`, no `protected` keyword in dart */
abstract class AWorker {

  final Wiso.Ports ports;
  Ft.Option<Gameboy.GameBoy> gb = new Ft.Option.none();

  AWorker(this.ports);

}

/** Concrete Worker */
class Worker extends AWorker
  with Workeremulation.Emulation
  , Workerdebug.Debug {

  // Debugger variables
  Worker(ports)
  : super(ports)
  {
    this.init_debug();
    this.init_emulation();
  }
}

Worker _globalWorker;

void entryPoint(Wiso.Ports p)
{
  print('worker:\tentryPoint($p)');
  assert(_globalWorker == null);
  _globalWorker = new Worker(p);
  return ;
}
