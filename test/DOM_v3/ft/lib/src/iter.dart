// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   iter.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/20 14:10:04 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/20 14:32:38 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

class DoubleIterable<T, U> {
  DoubleIterable(this._ita, this._itb) {
    assert(_ita.length == _itb.length);
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
