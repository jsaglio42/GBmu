// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   misc.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/15 10:47:48 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 16:16:45 by jsaglio          ###   ########.fr       //
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
