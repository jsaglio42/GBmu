// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/09 14:20:01 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/09 20:18:55 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Ht;
import 'dart:math' as Math;
import 'dart:async' as As;
import 'dart:isolate' as Iso;

// As.Future<Iso.Isolate> iso_fut;
// Iso.Isolate iso;

/*
 * Test at school 9aug2016, exp-log loop
 * 1worker :   18e6 opsPerSecPerWorker
 * 2workers:   17e6 opsPerSecPerWorker
 * 3workers:   17e6 opsPerSecPerWorker
 * 4workers:   17e6 opsPerSecPerWorker
 * 5workers: 11.5e6 opsPerSecPerWorker
 */

void dumpThreadInfo()
{
  print('Isolate: cur.hash(${Iso.Isolate.current.hashCode}), ');
  return ;
}

void iso_routine2(kwarg)
{
  print("Hello World isolate $kwarg");
  dumpThreadInfo();

  final Iso.SendPort toMainSend = kwarg['toMainSend'];
  assert(toMainSend != null);
  final toWorkerReceive = new Iso.ReceivePort();
  double d = 70.0;
  int i = 0;
  final int startMS = (new DateTime.now()).millisecondsSinceEpoch;
  int elapsMS;

  toMainSend.send(toWorkerReceive.sendPort);
  while (true)
  {
    if (i % (5 * 10e6) == 0)
    {
      elapsMS = (new DateTime.now()).millisecondsSinceEpoch - startMS;
      toMainSend.send('${Iso.Isolate.current.hashCode}: '
              '${elapsMS}ms: '
              '${i.toStringAsExponential(1)}ops '
              'd=$d. '
              '${(i * 1000 / elapsMS).toStringAsExponential(3)}opsPerSec');
    }
    i++;
    d = Math.exp(Math.log(d));
  }
  return ;
}

void iso_routine(kwarg)
{
  try {
    iso_routine2(kwarg);
  } catch (e) {
    print("Error Worker: $e");
  };
  return ;
}

main() async
{
  try {
    print('Hello World async');

    final Iso.ReceivePort toMainReceive = new Iso.ReceivePort();
    final Iso.Isolate myiso = await Iso.Isolate.spawn(iso_routine, {
      'toMainSend': toMainReceive.sendPort,
          'motDoux': "chouchou"
          });
    final Iso.SendPort toWorkerSend = await toMainReceive.first;

    // TODO: Can't receive that way because of previous .first call
    // toMainReceive.forEach((msg) {
    //     print("receivePort: $msg");
    //   });
    print('Bye World async');
    return ;
  } catch (e) {
    print("Error Main: $e");
  };
}
