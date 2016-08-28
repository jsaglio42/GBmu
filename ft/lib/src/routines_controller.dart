// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   routines_controller.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/28 14:24:05 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/28 18:17:10 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

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
    assert(T != dynamic, "Routine: can't have type dynamic");
    _controller.addRoutine(this);
  }

  Type get type => T;
  T get externalMode => _externalMode;
  WorkerMode get workerMode => _workerMode;

  void makeLooping()
  {
    assert(_workerMode == WorkerMode.Dormant, "makeLooping() while looping");
    this._workerMode = WorkerMode.Looping;
    _makeLooping();
  }

  void makeDormant()
  {
    assert(_workerMode == WorkerMode.Looping, "makeDormant() while dormant");
    this._workerMode = WorkerMode.Dormant;
    _makeDormant();
  }

  void changeExternalMode(T newMode)
  {
    Ft.log('Routine', '<$T>.changeExternalMode', newMode);
    if (newMode != _externalMode) {
      _externalMode = newMode;
      _controller.routineExternalModeChanged(T);
    }
  }

  bool conditionsMetForLoop(Map<Type, Routine> routines)
  {
    return _loopingConditions.every((cond){
          final Type t = cond.runtimeType;

          assert(routines[t] != null, "Missing routine $t in $routines");
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
    assert(_routines[r.type] == null, "Routine already present");
    assert(_fired == false, "Adding after firing");
    assert(r.workerMode == WorkerMode.Dormant, "Adding looping routine");
    _routines[r.type] = r;
  }

  void fireRoutines()
  {
    assert(_fired == false, "Firing after firing");
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
    assert(_routines[t] != null, "routineExternalMode($t)");
    return _routines[t].externalMode;
  }

}

// ************************************************************************** **
