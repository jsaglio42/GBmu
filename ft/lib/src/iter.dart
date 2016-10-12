// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   iter.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/20 14:10:04 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/15 12:11:28 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:async' as Async;
import 'dart:indexed_db' as Idb;

Iterable<List<Html.TableCellElement>> iterTableRows(Html.TableElement tab) sync*
{
  final List<Html.TableRowElement> rows = tab.rows;
  assert(rows != null);
  final Iterator<Html.TableRowElement> it = rows.iterator;

  while (it.moveNext())
    yield it.current.cells;
  return ;
}

Iterable<Map<String, dynamic>> iterEnumData(type, Iterable values)
sync* {
  final int prefixLength = type.toString().length + 1;
  int i = 0;

  for (var v in values) {
    yield {
      'value': v,
      'string': v.toString().substring(prefixLength),
      'index': i++,
    };
  }
  return ;
}

class DoubleIterable<T, U> {
  DoubleIterable(this._ita, this._itb) {
    assert(_ita.length == _itb.length,
        "ft.iter.DoubleIterable different lengths");
  }
  final Iterable<T> _ita;
  final Iterable<U> _itb;

  void forEach(void f(T, U)) {
    final Iterator<T> ita = _ita.iterator;
    final Iterator<U> itb = _itb.iterator;

    while (ita.moveNext() && itb.moveNext())
      f(ita.current, itb.current);
    return ;
  }
}

class TripleIterable<T, U, V> {
  TripleIterable(this._ita, this._itb, this._itc) {
    assert(_ita.length == _itb.length,
        "ft.iter.TripleIterable different lengths a/b");
    assert(_ita.length == _itc.length,
        "ft.iter.TripleIterable different lengths a/c");
  }
  final Iterable<T> _ita;
  final Iterable<U> _itb;
  final Iterable<V> _itc;

  void forEach(void f(T, U, V)) {
    final Iterator<T> ita = _ita.iterator;
    final Iterator<U> itb = _itb.iterator;
    final Iterator<V> itc = _itc.iterator;

    while (ita.moveNext() && itb.moveNext() && itc.moveNext())
      f(ita.current, itb.current, itc.current);
    return ;
  }
}

// Template method pattern
abstract class _IdbStoreIterator {

  final Idb.Transaction _tra;
  final Async.Stream<Idb.CursorWithValue> _cur;

  _IdbStoreIterator.transaction(Idb.Transaction tra, String storeName)
    : _tra = tra
    , _cur = tra
    .objectStore(storeName)
    .openCursor(autoAdvance: true);

  _IdbStoreIterator(Idb.Database db, String storeName, String mode)
    : this.transaction(db.transaction(storeName, mode), storeName);

}

// Callable class
class IdbStoreForeach<K, V> extends _IdbStoreIterator {

  IdbStoreForeach(Idb.Database db, String storeName)
    : super(db, storeName, 'readonly');

  Async.Future call(void fun(K k, V v)) {
    _cur.forEach((Idb.CursorWithValue cur) {
      fun(cur.key, cur.value);
    });
    return _tra.completed;
  }

}

// Callable class
class IdbStoreFold<K, V, T> extends _IdbStoreIterator {

  IdbStoreFold(Idb.Database db, String storeName)
    : super(db, storeName, 'readonly');

  Async.Future<T> call(T acc, T fun(T acc, K k, V v)) {
    _cur.forEach((Idb.CursorWithValue cur) {
      acc = fun(acc, cur.key, cur.value);
    });
    return _tra.completed.then((_) => acc);
  }

}
