// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   local_storage_components_intf.dart                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 14:36:42 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 17:59:27 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of local_storage_components;

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

class LsEvent {
  final String key;
  final String oldValue;
  final String newValue;
  const LsEvent(this.key, {String oldValue, String newValue})
      : oldValue = oldValue
      , newValue = newValue;
}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

abstract class LsEntry {

  // ATTRIBUTES ************************************************************* **
  Life _life;
  final Map<String, dynamic> _data;

  // CONTRUCTION ************************************************************ **
  factory LsEntry.json_exn(String keyJson, String valueJson) {

    final Map<String, dynamic> key = JSON.decode(keyJson);

    if (!key.containsKey('uid') || !(key['uid'] is int) || key['uid'] < 0)
      throw new Exception('Bad JSON $key');
    switch (key['type']) {
      case ('Rom') : return new LsRom.json_exn(key['uid'], valueJson);
      case ('Ram') : return new LsRam.json_exn(key['uid'], valueJson);
      case ('Ss') : return new LsSs.json_exn(key['uid'], valueJson);
      default: throw new Exception('Bad JSON $key');
    }
  }

  LsEntry._unsafe(this.uid, this.type, this._life, this._data);

  // PUBLIC ***************************************************************** **
  String get keyJson => JSON.encode({'uid': this.uid, 'type': '$type'});
  final int uid;
  final Component type;

  String get valueJson => JSON.encode(_data);
  Life get life => _life;
  int get idbid => _data['idbid'];
  String get fileName => _data['fileName'];

  void kill() {
    assert(_life is Alive, "$runtimeType.kill()");
    _life = Dead.v;
  }

  String toString() =>
    '$life $type uid#$uid idb#$idbid';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

class LsChip extends LsEntry {

  // CONTRUCTION ************************************************************ **
  LsChip._unsafe(int uid, Chip type, Life life, Map<String, dynamic> data)
    : super._unsafe(uid, type, life, data) {
    if (type is Ss)
      assert(data.containsKey('slot') == data.containsKey('romUid'),
          "from: LsChip._unsafe()");
  }

  factory LsChip.unbind(LsChip c) {
    final Map<String, dynamic> data = new Map.from(c._data);

    assert(c.isBound, "LsChip.unbind($c)");
    assert(c.life is Alive, "LsChip.unbind($c)");
    data.remove('romUid');
    data.remove('slot');
    if (c.type is Ram)
      return new LsRam._unsafe(c.uid, Alive.v, data);
    else
      return new LsSs._unsafe(c.uid, Alive.v, data);
  }

  factory LsChip.bind(LsChip c, int romUid, [int slot]) {
    final Map<String, dynamic> data = new Map.from(c._data);

    assert(c.life is Alive, "LsChip.bind($c, $romUid, $slot)");
    assert((c.type is Ss) == (slot != null), "LsChip.bind($c, $romUid, $slot)");
    data['romUid'] = romUid;
    if (c.type is Ram)
      return new LsRam._unsafe(c.uid, Alive.v, data);
    else {
      data['slot'] = slot;
      return new LsSs._unsafe(c.uid, Alive.v, data);
    }
  }

  // PUBLIC ***************************************************************** **
  bool get isBound => _data.containsKey('romUid');

  Ft.Option<int> get romUid => isBound
    ? new Ft.Option<int>.some(_data['romUid'])
    : new Ft.Option<int>.none();

  Ft.Option<int> get slot => isBound
    ? new Ft.Option<int>.some(_data['slot'])
    : new Ft.Option<int>.none();

  String toString() =>
    '${super.toString()} (rom '
    '${isBound ? "#${romUid.v} in ${slot.v}" : "none"}'
    ')';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **
