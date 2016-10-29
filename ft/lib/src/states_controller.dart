// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   states_controller.dart                             :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/29 09:22:48 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/29 15:16:39 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

typedef void t_thunk();

class _SideEffect {

  final t_thunk enable;
  final t_thunk disable;
  final List<List> _activationCombinations;
  bool active = false;

  _SideEffect(this.enable, this.disable, this._activationCombinations);

  bool activable(StatesController contr)
  {
    return this._activationCombinations
      .any((List cond){
        return cond.every((dynamic state) {
          final Type t = contr._typeOfState[state];
          final st = contr._stateOfType[t];

          assert(t != null && st != null,
              '_SideEffect <${state.runtimeType}>$state not found ($t, $st)');
          return st == state;
        });
      });
  }

}

class StatesController {

  final Map<Type, dynamic> _stateOfType = <Type, dynamic>{};
  final Map<dynamic, Type> _typeOfState = <dynamic, Type>{};
  final List<_SideEffect> _sideEffects = <_SideEffect>[];
  bool _fired = false;

  // BEFORE FIRE PHASE ****************************************************** **
  void declareType(Type t, Iterable states, dynamic startState) {
    _stateOfType[t] = startState;
    for (var s in states) {
      _typeOfState[s] = t;
      // print('declareType ${t} ${s} ${_typeOfState[s]} ${_typeOfState[s] == t}');
    }
  }

  void addSideEffect(
      t_thunk enable, t_thunk disable, List<List> activationCombinations)
  {
    assert(_fired == false, "Adding after firing");
    _sideEffects.add(new _SideEffect(enable, disable, activationCombinations));
  }

  void fire()
  {
    assert(_fired == false, "Firing after firing");
    _fired = true;
    _updateSideEffects();
  }

  // AFTER FIRE PHASE ******************************************************* **
  dynamic getState(Type t)
  {
    assert(_stateOfType[t] != null, "states_controller: getState($t)");
    return _stateOfType[t];
  }

  void setState(dynamic st)
  {
    final Type t = _typeOfState[st];

    assert(_fired);
    assert(t != null);
    _stateOfType[t] = st;
    _updateSideEffects();
  }

  void _updateSideEffects()
  {
    _sideEffects.forEach((_SideEffect se){
      if (se.activable(this)) {
        if (se.active == false) {
          se.active = true;
          se.enable();
        }
      }
      else {
        if (se.active == true) {
          se.active = false;
          se.disable();
        }
      }
    });
  }

}
