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

main()
{
	var	emu = new Emulator.Emulator(); 

	print('lulz');
	emu.onCPUUpdate
		.listen((map) => print('Main: onCPUUpdate $map'));

	print('lolz');
	var magbut = HTML.querySelector('#magbut');
	magbut.onClick.listen((_) {
		print('Main: onClick');
		emu.startEmulation('tamere');
	});
	print('lilz');
}

