// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_states.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/28 11:23:11 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/28 14:20:11 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// ************************************************************************** **

enum WorkerMode {
  Looping, Dormant
}

// ************************************************************************** **

typedef void t_workerModeUpdater();

class Routine<T> {

  T _externalMode;
  WorkerMode _workerMode;

  final RoutinesController _controller;
  final List _loopingConditions;
  final t_workerModeUpdater _makeLooping;
  final t_workerModeUpdater _makeDormant;

  Routine(
      this._controller,
      this._loopingConditions,
      this._makeLooping, this._makeDormant,
      this._externalMode
          )
    : _workerMode = WorkerMode.Dormant
  {
    assert(T != dynamic); //, "Routine: can't have type dynamic");
    _controller.addRoutine(this);
  }

  Type get type => T;
  T get externalMode => _externalMode;
  WorkerMode get workerMode => _workerMode;

  void makeLooping()
  {
    assert(_workerMode == WorkerMode.Dormant); //, "makeLooping() while looping");
    this._workerMode = WorkerMode.Looping;
    _makeLooping();
  }

  void makeDormant()
  {
    assert(_workerMode == WorkerMode.Looping); //, "makeDormant() while dormant");
    this._workerMode = WorkerMode.Dormant;
    _makeDormant();
  }

  void changeExternalMode(T newMode)
  {
    print('Routine' + '   ' + '<$T>.changeExternalMode' '($newMode)');
    assert(newMode != _externalMode); //, "changeExternalMode($newMode)");
    _externalMode = newMode;
    _controller.routineExternalModeChanged(T);
  }

  bool conditionsMetForLoop(Map<Type, Routine> routines)
  {
    return _loopingConditions.every((cond){
          final Type t = cond.runtimeType;

          assert(routines[t] != null); //, "Missing routine $t in $_routines");
          return routines[t].externalMode == cond;
        });
  }

}

// ************************************************************************** **

class RoutinesController {

  Map<Type, Routine> _routines = {};
  bool _fired = false;

  void addRoutine(Routine r)
  {
    assert(_routines[r.type] == null); //, "Routine already present");
    assert(_fired == false); //, "Adding after firing");
    assert(r.workerMode == WorkerMode.Dormant); //, "Adding looping routine");
    _routines[r.type] = r;
  }

  void fireRoutines()
  {
    assert(_fired == false); //, "Firing after firing");
    _fired = true;
    _updateRoutineWorkersMode();
  }

  void _updateRoutineWorkersMode()
  {
    _routines.forEach((_, v){
      if (v.conditionsMetForLoop(_routines)) {
        if (v.workerMode == WorkerMode.Dormant)
          v.makeLooping();
      }
      else {
        if (v.workerMode == WorkerMode.Looping)
          v.makeDormant();
      }
    });
  }

  void routineExternalModeChanged(Type t)
  {
    _updateRoutineWorkersMode();
  }

  // ************************************************************************ **

  dynamic getExtMode(Type t)
  {
    assert(_routines[t] != null); //, "routineExternalMode($t)");
    return _routines[t].externalMode;
  }


}

// ************************************************************************** **





// ************************************************************************** **

enum DebuggerExternalMode {
  Operating, Dismissed
}

enum GameBoyExternalMode {
  Emulating, Paused, Crashed, Absent
}

enum ObserverExternalMode {
  Operating
}

// ************************************************************************** **

var whenDebuggerLooping =
  [GameBoyExternalMode.Emulating, DebuggerExternalMode.Operating]
  ;

var whenGameBoyLooping =
  [GameBoyExternalMode.Emulating]
  ;

var whenObserverLooping =
  [GameBoyExternalMode.Emulating, ObserverExternalMode.Operating]
;

main () {
  print('Hello World');

  var c = new RoutinesController();

  var deb = new Routine<DebuggerExternalMode>(
      c, whenDebuggerLooping,
      (){
        print('debugger\t makeLooping');
      },
      (){
        print('debugger\t makeDormant');
      },
      DebuggerExternalMode.Operating
                        );

  var gb = new Routine<GameBoyExternalMode>(
      c, whenGameBoyLooping,
      (){
        print('gameboy \t makeLooping');
      },
      (){
        print('gameboy \t makeDormant');
      },
      GameBoyExternalMode.Absent

                        );

  var obs = new Routine<ObserverExternalMode>(
      c, whenObserverLooping,
      (){
        print('observer\t makeLooping');
      },
      (){
        print('observer\t makeDormant');
      },
      ObserverExternalMode.Operating
                        );

  print('fire...');
  c.fireRoutines();
  print('gb start...');
  gb.changeExternalMode(GameBoyExternalMode.Emulating);

  print('gb pause...');
  gb.changeExternalMode(GameBoyExternalMode.Paused);
  print('gb resume...');
  gb.changeExternalMode(GameBoyExternalMode.Emulating);

  print('gb crash...');
  gb.changeExternalMode(GameBoyExternalMode.Crashed);
  print('gb eject...');
  gb.changeExternalMode(GameBoyExternalMode.Absent);
  print('gb start...');
  gb.changeExternalMode(GameBoyExternalMode.Emulating);

  print('deb dismiss..');
  deb.changeExternalMode(DebuggerExternalMode.Dismissed);
  print('gb eject...');
  gb.changeExternalMode(GameBoyExternalMode.Absent);
  print('deb turn on..');
  deb.changeExternalMode(DebuggerExternalMode.Operating);
  print('gb start...');
  gb.changeExternalMode(GameBoyExternalMode.Emulating);
}
