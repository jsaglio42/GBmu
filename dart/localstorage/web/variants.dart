// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   variants.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 12:12:05 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 18:38:00 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// Slot event *************************************************************** **

abstract class SlotEvent {
  const SlotEvent();
}

class Arrival extends SlotEvent {
  const Arrival();
  static const Arrival v = const Arrival();
}

class Dismissal extends SlotEvent {
  const Dismissal();
  static const Dismissal v = const Dismissal();
}

// Update event ************************************************************* **

class Update<T> {
  final T newValue;
  final T oldValue;
  Update(this.newValue, this.oldValue);
}

// Components *************************************************************** **

abstract class Component {
  const Component();
}

abstract class Chip extends Component {
  const Chip();
}

class Rom extends Component {
  const Rom();
  static const Rom v = const Rom();
  String toString() => 'Rom';
}

class Ram extends Chip {
  const Ram();
  static const Ram v = const Ram();
  String toString() => 'Ram';
}

class Ss extends Chip {
  const Ss();
  static const Ss v = const Ss();
  String toString() => 'Ss';
}

// Status ******************************************************************* **

abstract class Status {
  const Status();
}

class Enabled extends Status {
  const Enabled();
  static const Enabled v = const Enabled();
  String toString() => 'Enabled';
}

class Disabled extends Status {
  const Disabled();
  static const Disabled v = const Disabled();
  String toString() => 'Disabled';
}

// Life ********************************************************************* **

abstract class Life {
  const Life();
  factory Life.ofString(String s) {
    switch (s) {
      case ('Alive'): return Alive.v;
      case ('Dead'): return Dead.v;
      default: throw new Exception('Life.ofString($s)');
    }
  }
}

class Alive extends Life {
  const Alive();
  static const Alive v = const Alive();
  String toString() => 'Alive';
}

class Dead extends Life {
  const Dead();
  static const Dead v = const Dead();
  String toString() => 'Dead';
}
