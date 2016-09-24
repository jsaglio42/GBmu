// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   option.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/20 14:10:04 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/28 10:15:43 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

class Option<T> {

  Option.none() : this.v = null;
  Option.some(this.v);

  bool get isSome => this.v != null;
  bool get isNone => this.v == null;

  final T v;

}