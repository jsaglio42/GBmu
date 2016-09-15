// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   component_system.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 14:48:01 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/15 17:05:44 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/filedb.dart' as Emufiledb;

import './toplevel_banks.dart';

// PRIVATE ****************************************************************** **

// PUBLIC ******************************************************************* **

Emufiledb.DatabaseProxy g_dbProxy;
CartBank g_cartBank;
DetachedChipBank g_dChipBank;
GameBoySocket g_gbSocket;
