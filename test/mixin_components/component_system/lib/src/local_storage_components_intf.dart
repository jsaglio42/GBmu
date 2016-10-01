// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   local_storage_components_intf.dart                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 14:36:42 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/01 17:19:32 by ngoguey          ###   ########.fr       //
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

  LsEntry._unsafe(this.uid, this.type, this._life, this.idbid);

  // PUBLIC ***************************************************************** **
  String get keyJson => JSON.encode({'uid': this.uid, 'type': '$type'});
  final int uid;
  final Component type;

  String get valueJson;
  Life get life => _life;
  final int idbid;

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

abstract class LsChip implements LsEntry {

  // CONTRUCTION ************************************************************ **
  factory LsChip.unbind(LsChip c) {
    assert(c.isBound, "LsChip.unbind($c)");
    assert(c.life is Alive, "LsChip.unbind($c)");

    if (c.type is Ram)
      return new LsRam.unbind(c);
    else
      return new LsSs.unbind(c);
  }

  factory LsChip.bind(LsChip c, int romUid, [int slot]) {
    assert(!c.isBound, "LsChip.bind($c)");
    assert(c.life is Alive, "LsChip.bind($c)");

    if (c.type is Ram)
      return new LsRam.bind(c, romUid);
    else
      return new LsSs.bind(c, romUid, slot);
  }

  // PUBLIC ***************************************************************** **
  bool get isBound;
  Ft.Option<int> get romUid;
  Ft.Option<int> get slot;

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

abstract class _LsRomParent extends LsEntry implements LsChip {

  // CONTRUCTION ************************************************************ **
  _LsRomParent._unsafe(int uid, Chip type, Life life, int idbid, this.romUid)
    : super._unsafe(uid, type, life, idbid);

  // PUBLIC ***************************************************************** **
  bool get isBound => romUid.isSome;
  final Ft.Option<int> romUid;
  Ft.Option<int> get slot => new Ft.Option<int>.none();

  String toString() =>
    '${super.toString()} (rom ${isBound ? "#${romUid.v}" : "none"})';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

abstract class _LsRomParentSlot extends LsEntry implements LsChip {

  // CONTRUCTION ************************************************************ **
  _LsRomParentSlot._unsafe(
      int uid, Chip type, Life life, int idbid, this.romUid, this.slot)
    : super._unsafe(uid, type, life, idbid) {
    assert(romUid.isSome == slot.isSome, "from: _LsRomParentSlot._unsafe()");
  }

  // PUBLIC ***************************************************************** **
  bool get isBound => romUid.isSome;
  final Ft.Option<int> romUid;
  final Ft.Option<int> slot;

  String toString() =>
    '${super.toString()} (rom '
    '${isBound ? "#${romUid.v} in ${slot.v}" : "none"}'
    ')';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **
