// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   states_controller.dart                             :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/29 09:22:48 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/29 10:15:03 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

typedef void t_thunk();

class _SideEffect {

  final t_thunk enable;
  final t_thunk disable;
  final List<List> _activationCombinations;
  bool active = false;

  _SideEffect(this.enable, this.disable, this._activationCombinations);

  bool activable(Map<Type, dynamic> states)
  {
    return this._activationCombinations
      .any((List cond){
        return cond.every((dynamic state) {
          var st = states[state.runtimeType];

          if (st == null)
            return false;
          else
            return st == state;
        });
      });
  }

}

class StatesController {

  Map<Type, dynamic> _states = {};
  List<_SideEffect> _sideEffects = [];
  bool _fired = false;

  void addSideEffect(
      t_thunk enable, t_thunk disable, List<List> activationCombinations)
  {
    assert(_fired == false, "Adding after firing");
    _sideEffects.add(new _SideEffect(enable, disable, activationCombinations));
  }

  void setState(dynamic st)
  {
    _states[st.runtimeType] = st;
    if (_fired)
      _updateSideEffects();
  }

  void fire()
  {
    assert(_fired == false, "Firing after firing");
    _fired = true;
    _updateSideEffects();
  }

  void _updateSideEffects()
  {
    _sideEffects.forEach((_SideEffect se){
      if (se.activable(_states)) {
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

  dynamic getState(Type t)
  {
    assert(_states[t] != null, "states_controller: getState($t)");
    return _states[t];
  }

}
