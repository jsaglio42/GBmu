// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/15 15:01:17 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:isolate' as Isolate;
import 'dart:async' as Async;
import 'wired_isolate.dart' as WI;

WI.Ports g_p;

void onEmulationStart(int p)
{
  print('worker.onEmulationStart($p)');
  g_p.send('RegInfo', <String, int>{
    'rpb': 12,
    'eax': 15,
  });
  return ;
}

void onEmulationMode(String p)
{
  print('worker.onEmulationMode($p)');
  return ;
}

void entryPoint(WI.Ports p) {
  g_p = p;
  print('Worker:entryPoint($p)');

  p.listener('EmulationStart').listen(onEmulationStart);
  p.listener('EmulationMode').listen(onEmulationMode);
  return ;
}
