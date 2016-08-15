// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/15 16:45:59 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:isolate' as Isolate;
import 'dart:async' as Async;
import 'wired_isolate.dart' as WI;

class Worker {

  Worker(this._ports)
  {
    _ports.listener('EmulationStart').listen(_onEmulationStart);
    _ports.listener('EmulationMode').listen(_onEmulationMode);
  }
  final WI.Ports _ports;

  void _onEmulationStart(int p)
  {
    print('worker:\tonEmulationStart($p)');
    _ports.send('RegInfo', <String, int>{
      'rpb': 12,
      'eax': 15,
    });
    return ;
  }

  void _onEmulationMode(String p)
  {
    print('worker:\tonEmulationMode($p)');
    return ;
  }
}

Worker _globalWorker;

void entryPoint(WI.Ports p)
{
  print('worker:\tentryPoint($p)');

  assert(_globalWorker == null);
  _globalWorker = new Worker(p);
  return ;
}
