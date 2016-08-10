// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   view.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/09 14:20:01 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/09 20:18:55 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "view.html" as HTML;

var registersDiv = HTML.querySelector('#registers');

void prepareView(Stream stream)
{
	/* Fist idea */

	// var pouetSubscription = button_pouet.onClick
	// 	.listen(printPouet);
	// var debugSubscritpion = debugReceivePort. ???
	// .listen((msg) {
	// 	assert(msg['type'] != null);
	// 	assert(msg['type'] is String);
	// 	switch (msg['type']) {
	// 		case('registersUpdate'): updateRegisters(msg['data']);
	// }


	// })

	/* Second Idea */

	var registerSubscribe = stream.filter(x => x is EventRegister???).listen(updateRegister);

	var registerSubscribe = stream.filter(x => x is EventRegister???).listen(updateRegister);
	
	return ;
}

void printPouet(event)
{
	print('Pouet');
	return ;
}

void updateRegisters(Map<String, Int> message)
{
	assert(msg['type'] != null);
	assert(msg['type'] is String);
	registersDiv.
	print('Pouet');
	return ;
}