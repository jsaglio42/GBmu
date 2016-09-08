// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   wired_isolate.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/15 10:47:48 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/30 14:20:36 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

String   toAddressString(int value, int padding) {
  return ('0x' + toHexaString(value, padding));
}

String   toHexaString(int value, int padding) {
  return (value.toRadixString(16).toUpperCase().padLeft(padding, "0"));
}