// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   joypad_key.dart                                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 15:33:47 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 18:09:25 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class JoypadKeyInfo {

  final String name;
  final List<Key> defaultMapping;

  const JoypadKeyInfo(this.name, this.defaultMapping);

}

const Map<JoypadKey, JoypadKeyInfo> joypadInfo =
  const <JoypadKey, JoypadKeyInfo>{
    JoypadKey.Up: const JoypadKeyInfo("UP", const <Key>[
      const Key("KeyW", 87, false, false, false, false),
      const Key("KeyW", 87, false, false, false, true),
      const Key("KeyW", 87, false, true, false, false),
    ]),
    JoypadKey.Left: const JoypadKeyInfo("LEFT", const <Key>[
      const Key("KeyA", 65, false, false, false, false),
      const Key("KeyA", 65, false, false, false, true),
      const Key("KeyA", 65, false, true, false, false),
    ]),
    JoypadKey.Down: const JoypadKeyInfo("DOWN", const <Key>[
      const Key("KeyS", 83, false, false, false, false),
      const Key("KeyS", 83, false, false, false, true),
      const Key("KeyS", 83, false, true, false, false),
    ]),
    JoypadKey.Right: const JoypadKeyInfo("RIGHT", const <Key>[
      const Key("KeyD", 68, false, false, false, false),
      const Key("KeyD", 68, false, false, false, true),
      const Key("KeyD", 68, false, true, false, false),
    ]),

    JoypadKey.Select: const JoypadKeyInfo("SELECT", const <Key>[
      const Key("Backspace", 8, false, false, false, false),
      const Key("Backspace", 8, false, false, false, true),
      const Key("Backspace", 8, false, true, false, false),
    ]),
    JoypadKey.Start: const JoypadKeyInfo("START", const <Key>[
      const Key("Enter", 13, false, false, false, false),
      const Key("Enter", 13, false, false, false, true),
      const Key("Enter", 13, false, true, false, false),
    ]),
    JoypadKey.B: const JoypadKeyInfo("B", const <Key>[
      const Key("KeyK", 75, false, false, false, false),
      const Key("KeyK", 75, false, false, false, true),
      const Key("KeyK", 75, false, true, false, false),
    ]),
    JoypadKey.A: const JoypadKeyInfo("A", const <Key>[
      const Key("KeyL", 76, false, false, false, false),
      const Key("KeyL", 76, false, false, false, true),
      const Key("KeyL", 76, false, true, false, false),
    ]),
  };
