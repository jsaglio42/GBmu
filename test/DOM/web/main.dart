// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/09 14:20:01 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/09 20:18:55 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'emulator.dart' as Emulator;
import 'dart:html' as HTML;

main() async
{
	var	emu = new Emulator.Emulator(); 
	emu.onCPUUpdate
		.listen((map) => print('Main: onCPUUpdate $map'));

	var magbut = HTML.querySelector('#magbut');
	magbut.onClick((_) {
		print('Main: onClick');
		emu.startEmulation('tamere');
	});
}

