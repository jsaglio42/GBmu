// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   debug.dart                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/27 11:08:37 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/27 12:13:07 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// http://blog.sethladd.com/2013/12/compile-time-dead-code-elimination-with.html
const _enabled = const String.fromEnvironment('FTLOG') != null;

DateTime now() => new DateTime.now();

void log(String where, String function, [var param]) {
  if (_enabled) {
    final n = now();
    final f = (int v, int w) => v.toString().padLeft(w, '0');
    final g = (v, int w) => v.toString().padRight(w);
    final b = new StringBuffer()
      ..write('${f(n.hour, 2)}:')
      ..write('${f(n.minute, 2)}:')
      ..write('${f(n.second, 2)}.')
      ..write('${f(n.millisecond, 3)}')
      ..write(' ')
      ..write(g(where, 14))
      ..write(function)
      ..write("(${param != null ? param : ''})");
    print(b);
  }
  return ;
}
