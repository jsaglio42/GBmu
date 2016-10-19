// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   misc.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/15 10:47:48 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 16:04:35 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

String   toAddressString(int value, int padding) {
  return ('0x${toHexaString(value, padding)}');
}

String   toColorString(int value) {
  return ('#${toHexaString(value, 6)}');
}

String   toHexaString(int value, int padding) {
  return (value.toRadixString(16).toUpperCase().padLeft(padding, "0"));
}

void fillBuffer(List<int> buffer, int v) {
buffer.fillRange(0, buffer.length, v);
return ;
}
