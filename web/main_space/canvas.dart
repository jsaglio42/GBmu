// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   canvas.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:37:10 by jsaglio           #+#    #+#             //
//   Updated: 2016/09/28 12:23:32 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;

import 'package:emulator/enums.dart';

import 'package:emulator/emulator.dart' as Emulator;

Emulator.Emulator _emu;
Html.CanvasElement _canvas = Html.querySelector('#gameboyScreen');
// Html.CanvasRenderingContext2D _ctx = _canvas.context2D;

void init(Emulator.Emulator emu) {
  _emu = emu;
  /* Implement Other stuff */
  _canvas.context2D
    ..fillStyle = 'White'
    ..strokeStyle = 'White';

  _canvas.context2D
    ..fillRect(0, 0, 10, 10)
    ..strokeRect(0, 0, 10, 10);
  return ;
}

/* Private ********************************************************************/
