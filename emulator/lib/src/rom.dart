// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   rom.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:56:08 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/23 14:59:52 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as As;

class Rom {

	ListUInt8 	_data;
	
	Rom(this._data) {
	}

	int get mbcType => _data[0x0147]
	String get title => "Swag";

}