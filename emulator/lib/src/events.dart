// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   events.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/18 11:11:29 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 22:49:17 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import './enums.dart';

class EventIdb {

  final String idb;
  final String store;
  final int key;

  EventIdb(this.idb, this.store, this.key);

}

class RequestEmuStart {

  final String idb;
  final String romStore;
  final String ramStore;

  final int romKey;
  final int ramKeyOpt;

  RequestEmuStart({
    this.idb, this.romStore, this.ramStore, this.romKey, this.ramKeyOpt});

}

class RequestJoypad {

  JoypadKey key;
  JoypadActionType type;
  bool press;

  RequestJoypad(this.key, this.type, this.press);

  RequestJoypad.copy(RequestJoypad src)
    : key = JoypadKey.values[src.key.index]
    , type = JoypadActionType.values[src.type.index]
    , press = src.press;

}