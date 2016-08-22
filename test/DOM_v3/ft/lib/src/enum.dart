// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   enum.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/20 12:34:57 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/20 13:56:55 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

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
