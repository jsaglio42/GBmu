// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   option.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/20 14:10:04 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 16:47:46 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

class Option<T> {

  Option.none() : this.data = null;
  Option.some(this.data);

  bool get isSome => T != null;
  bool get isNone => T == null;

  final T data;

}