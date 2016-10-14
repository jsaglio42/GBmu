// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   variants.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/09 11:40:01 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/13 18:53:38 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// COMPONENTS *************************************************************** **
abstract class Chip implements Component{}

abstract class Component {
  static const Iterable<Component> values =
    const <Component>[Rom.v, Ram.v, Ss.v];
}

class Rom implements Component {
  const Rom._();
  static const Rom v = const Rom._();
  String toString() => 'Rom';
}

class Ram implements Chip {
  const Ram._();
  static const Ram v = const Ram._();
  String toString() => 'Ram';
}

class Ss implements Chip {
  const Ss._();
  static const Ss v = const Ss._();
  String toString() => 'Ss';
}

// EMULATOR'S GAMEBOY STATE ************************************************* **
abstract class GameBoyState {
  static const Iterable<GameBoyState> values =
    const <GameBoyState>[Absent.v, Crashed.v, Emulating.v];
}

class Absent implements GameBoyState {
  const Absent._();
  static const Absent v = const Absent._();
  String toString() => 'Absent';
}

class Crashed implements GameBoyState {
  const Crashed._();
  static const Crashed v = const Crashed._();
  String toString() => 'Crashed';
}

class Emulating implements GameBoyState {
  const Emulating._();
  static const Emulating v = const Emulating._();
  String toString() => 'Emulating';
}

// EMULATOR'S EVENTS ******************************************************** **
abstract class EmulatorEvent {
  EmulatorEvent get reinstanciate;
}
abstract class GameBoyEvent implements EmulatorEvent {
  GameBoyState get src;
  GameBoyState get dst;
}
abstract class Error implements EmulatorEvent {}
abstract class Eject implements GameBoyEvent {}
abstract class EmulationBegin implements GameBoyEvent {}

// GAMEBOY EVENT - START SUCCESS ************************ **
class Start implements EmulatorEvent, GameBoyEvent, EmulationBegin {
  const Start._();
  static const Start v = const Start._();
  String toString() => 'Start';
  GameBoyState get src => Absent.v;
  GameBoyState get dst => Emulating.v;
  EmulatorEvent get reinstanciate => Start.v;
}

class CrashedRestart implements EmulatorEvent, GameBoyEvent, EmulationBegin {
  const CrashedRestart._();
  static const CrashedRestart v = const CrashedRestart._();
  String toString() => 'CrashedRestart';
  GameBoyState get src => Crashed.v;
  GameBoyState get dst => Emulating.v;
  EmulatorEvent get reinstanciate => CrashedRestart.v;
}

class EmulatingRestart implements EmulatorEvent, GameBoyEvent, EmulationBegin {
  const EmulatingRestart._();
  static const EmulatingRestart v = const EmulatingRestart._();
  String toString() => 'EmulatingRestart';
  GameBoyState get src => Emulating.v;
  GameBoyState get dst => Emulating.v;
  EmulatorEvent get reinstanciate => EmulatingRestart.v;
}

// GAMEBOY EVENT - START FAILURE ************************ **
class StartError implements EmulatorEvent, GameBoyEvent, Error {
  const StartError._();
  static const StartError v = const StartError._();
  String toString() => 'StartError';
  GameBoyState get src => Absent.v;
  GameBoyState get dst => Absent.v;
  EmulatorEvent get reinstanciate => StartError.v;
}

class CrashedRestartError implements EmulatorEvent, GameBoyEvent, Error {
  const CrashedRestartError._();
  static const CrashedRestartError v = const CrashedRestartError._();
  String toString() => 'CrashedRestartError';
  GameBoyState get src => Crashed.v;
  GameBoyState get dst => Absent.v;
  EmulatorEvent get reinstanciate => CrashedRestartError.v;
}

class EmulatingRestartError implements EmulatorEvent, GameBoyEvent, Error {
  const EmulatingRestartError._();
  static const EmulatingRestartError v = const EmulatingRestartError._();
  String toString() => 'EmulatingRestartError';
  GameBoyState get src => Emulating.v;
  GameBoyState get dst => Absent.v;
  EmulatorEvent get reinstanciate => EmulatingRestartError.v;
}

// GAMEBOY EVENT - EJECT ******************************** **
class EmulatingEject implements EmulatorEvent, GameBoyEvent, Eject {
  const EmulatingEject._();
  static const EmulatingEject v = const EmulatingEject._();
  String toString() => 'EmulatingEject';
  GameBoyState get src => Emulating.v;
  GameBoyState get dst => Absent.v;
  EmulatorEvent get reinstanciate => EmulatingEject.v;
}

class CrashedEject implements EmulatorEvent, GameBoyEvent, Eject {
  const CrashedEject._();
  static const CrashedEject v = const CrashedEject._();
  String toString() => 'CrashedEject';
  GameBoyState get src => Crashed.v;
  GameBoyState get dst => Absent.v;
  EmulatorEvent get reinstanciate => CrashedEject.v;
}

// GAMEBOY EVENT - MISC. ******************************** **
class Crash implements EmulatorEvent, GameBoyEvent, Error {
  const Crash._();
  static const Crash v = const Crash._();
  String toString() => 'Crash';
  GameBoyState get src => Emulating.v;
  GameBoyState get dst => Crashed.v;
  EmulatorEvent get reinstanciate => Crash.v;
}

// EMULATOR EVENT - MISC. ******************************* **
// Sent from main-isolate, after an isolate crash
class EmulatorCrash implements EmulatorEvent, Error {
  const EmulatorCrash._();
  static const EmulatorCrash v = const EmulatorCrash._();
  String toString() => 'EmulatorCrash';
  EmulatorEvent get reinstanciate => EmulatorCrash.v;
}
