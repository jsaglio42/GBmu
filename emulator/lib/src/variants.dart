// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   variants.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/09 11:40:01 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/09 11:40:07 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

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
