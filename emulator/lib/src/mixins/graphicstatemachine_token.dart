// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphicstatemachine_token.dart                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/31 18:38:35 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/31 19:00:58 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/shared.dart" as Shared;

abstract class GraphicStateMachineToken {

  /* PRIVATE ******************************************************************/
  bool _frameRenderToken = true;
  bool _renderingFrame = true;

  /* WORKER API ***************************************************************/
  void gsmt_touchFrameRenderToken() {
    _frameRenderToken = true;
  }

  /* STATE MACHINE API ********************************************************/
  bool get gsmt_shouldRender {
    return _renderingFrame;
  }

  void gsmt_VBLANKDone() {
    if (_frameRenderToken)
      _renderingFrame = true;
    else
      _renderingFrame = false;
    _frameRenderToken = false;
  }

}