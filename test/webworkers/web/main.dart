// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/09 14:20:01 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/09 16:31:03 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Ht;
import 'dart:math' as Math;
import 'dart:async' as As;
import 'dart:isolate' as Iso;

As.Future<Iso.Isolate> iso_fut;
Iso.Isolate iso;

/*
 * Test at school 9aug2016, exp-log loop
 * 1worker :   18e6 opsPerSecPerWorker
 * 2workers:   17e6 opsPerSecPerWorker
 * 3workers:   17e6 opsPerSecPerWorker
 * 4workers:   17e6 opsPerSecPerWorker
 * 5workers: 11.5e6 opsPerSecPerWorker
 */

void dumpThreadInfo() {
  print('Isolate: cur.hash(${Iso.Isolate.current.hashCode}), ');
  return ;
}

void iso_routine(message) {
  double d = 70.0;
  int i = 0;
  final int startMS = (new DateTime.now()).millisecondsSinceEpoch;
  int elapsMS;
  print("Isolate BODY !!! $message");
  dumpThreadInfo();
  while (true) {
    if (i % (5 * 10e6) == 0) {
      elapsMS = (new DateTime.now()).millisecondsSinceEpoch - startMS;
      print('${Iso.Isolate.current.hashCode}: '
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

void onIsoCreated(Iso.Isolate i) {
  print('Iso created !!! ${i.hashCode}');
  dumpThreadInfo();
  iso = i;
  return ;
}

As.Future ft_truc() async {
  print('Hello World async');
  Iso.Isolate myiso = await Iso.Isolate.spawn(iso_routine, 'hello mec1');
  onIsoCreated(myiso);
  // Iso.Isolate.spawn(iso_routine, 'hello mec5');
  // iso_fut.then(onIsoCreated);
  // iso_fut.then(onIsoCreated);
  // iso_fut.then(onIsoCreated);
  print('Bye World async');
}

main () {
  print('Hello World');
  dumpThreadInfo();
  // var element = Ht.querySelector('#hellol');
  // element.text = "Salut Jano";
  // element.text = 'web worker supported: ${Ht.Worker.supported}';
  ft_truc();
  print('Bye World');
}