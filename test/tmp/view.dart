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

var button_pouet = HTML.querySelector('#button-pouet');
var registersDiv = HTML.querySelector('#registers');
var button_pouet = HTML.querySelector('#button-pouet');
var button_pouet = HTML.querySelector('#button-pouet');

void prepareView(LCDreceivePort, debugReceivePort)
{
	var pouetSubscription = button_pouet.onClick
		.listen(printPouet);
	debugReceivePort.listen()

	return ;
}

void printPouet(event)
{
	print('Pouet');
	return ;
}

void updateRegisters(Map<String, Int> message)
{
	registersDiv.
	print('Pouet');
	return ;
}