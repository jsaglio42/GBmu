// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   controller_database.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/22 17:19:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/22 19:25:51 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

enum IdbStoreBinary {
  Rom, Ram, Ss,
}

/*
 * {'binaryKey': int,
 */
enum IdbStoreMeta {
  Rom, Ram, Ss,
}

class IdbEntry<TStore> {

  final TStore store;
  final int key;
  IdbEntry(this.store, this.key);

}

class IdbEntryEcho<TStore, TVal> extends IdbEntry<TStore> {

  final TVal val;

  IdbEntryEcho(TStore store, int key, this.val)
    : super(store, key);

}

class IdbStoreEcho<TStore, TVal> {
  List<IdbEntryEcho<TStore, TVal>> list;
}

// ************************************************************************** **

class IdbStoreDiff<TStore> {

  final List<IdbEntry<TStore>> _newEntryList;
  final List<IdbEntry<TStore>> _deletedEntryList;

}

class IdbStoreEchoDiff<TStore, TVal> extends IdbStoreDiff<TStore> {

  final List<IdbEntryEcho<TStore, TVal>> _updatedEntryList;

}


// ************************************************************************** **

class IdbStore<TStore> {

  final TStore store;
  Map<int, IdbEntry<TStore>> _entryMap;

  IdbStoreDiff<TStore> update(Idb.Database db) {

  }
}

class IdbStoreEcho<TStore, TVal> extends IdbStore<TStore> {

  Map<int, IdbEntryEcho<TStore, TVal>> get _entryMap => super._entryMap;

  @override
  IdbStoreEchoDiff<TStore, TVal> update(Idb.Database db) {

  }

}

// ************************************************************************** **
class ControllerDbData<TStore, TVal> {

  Map<TStore, IdbStoreEcho<TStore, TVal>> storeEchoMap;

  async update(db) {

  }

  Future<IdbDiff> _computeDiff(db, Iterable stores) async {

  }

  Future<>

  Future<IdbStoreEcho<TStore, TVal>> _comptureStoreEcho(
      Idb.Database db, TStore store) async
  {

    return ;
  }

}


class ControllerDb {

  final Idb.IdbFactory _dbf;
  Idb.Database _db;

  ControllerDatabase(this._dbf);

  Async.Future open() async {
    assert(_db == null, "open() invalid");
    _db = await _dbf.open(DBNAME);
    _setCallbacks();
  }

  void _onVersionChange(_) {
    _db.close();
    _db = null;
    _open();
  }

  _setCallbacks() {
    _db.onClose.forEach((ev) => print('onClose($ev)'));
    _db.onError.forEach((ev) => print('onError($ev)'));
    _db.onAbort.forEach((ev) => print('onAbort($ev)'));
    _db.onVersionChange.forEach(_onVersionChange);
  }


}