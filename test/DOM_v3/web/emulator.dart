// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulator.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/15 15:04:23 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as As;
import 'dart:isolate' as Is;
import 'wired_isolate.dart' as WI;
import 'worker.dart' as W;

class Emulator {

  Emulator(Is.Isolate iso, WI.Ports p)
    : _iso = iso
    , _ports = p
  {
  }

  final Is.Isolate _iso;
  final WI.Ports _ports;

  void send(String n, var p) => _ports.send(n, p);
  As.Stream listener(String n) => _ports.listener(n);
}

As.Future<Emulator> create() async {
  print('emulator.create()');

  final fin = WI.spawn(W.entryPoint)
  ..catchError((e) {
        print(e);
      });
  final data = await fin;

  return new Emulator(data.i, data.p);
}
