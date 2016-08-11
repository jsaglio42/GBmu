// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/10 17:57:09 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'emulator.dart' as Emulator;
import 'dart:html' as HTML;
import 'dart:async' as Async;

main() async
{
	var	emu = await Emulator.create();

	var magbut = HTML.querySelector('#magbut');
	magbut.onClick.listen((_) {
		print('Main: onClick');
		emu.sendMessage('lol');
		emu.sendMessage(28);
		emu.sendMessage(21);
		emu.sendMessage(42);

	});
}
