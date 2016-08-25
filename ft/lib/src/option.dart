// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   option.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/20 14:10:04 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 14:50:54 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

class Option<T> {

  Option.none() : this.data = null;
  Option.some(this.data);

  bool get isSome => this.data != null;
  bool get isNone => this.data == null;

  final T data;

}