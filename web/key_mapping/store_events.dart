// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   store_events.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 16:58:33 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 20:20:37 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class StoreEvents {

  final Async.StreamController<KeyMap> _click =
    new Async.StreamController<KeyMap>.broadcast();
  void click(KeyMap that) => _click.add(that);
  Async.Stream<KeyMap> get onClick => _click.stream;

  final Async.StreamController<KeyMap> _doubleClick =
    new Async.StreamController<KeyMap>.broadcast();
  void doubleClick(KeyMap that) => _doubleClick.add(that);
  Async.Stream<KeyMap> get onDoubleClick => _doubleClick.stream;

  final Async.StreamController<KeyMap> _keyMapUpdate =
    new Async.StreamController<KeyMap>.broadcast();
  void keyMapUpdate(KeyMap that) => _keyMapUpdate.add(that);
  Async.Stream<KeyMap> get onKeyMapUpdate => _keyMapUpdate.stream;

}