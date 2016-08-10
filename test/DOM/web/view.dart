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

import "dart:html" as HTML;

void prepareView()
{
	var button_pouet = HTML.querySelector('#button-pouet');
	button_pouet.onClick.listen((event) => print('POUET'));
}