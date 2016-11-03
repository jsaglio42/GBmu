// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   config.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/03 10:58:00 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/03 11:12:33 by ngoguey          ###   ########.fr       //
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

class CsKeyInfo {

  final String name;
  final Cs.KeyboardAction action;
  final Key defaultMapping;

  const CsKeyInfo(this.name, this.action, this.defaultMapping);

}

const List<CsKeyInfo> ssKeyInfo = const <CsKeyInfo>[
  const CsKeyInfo("Install from slot #1", Cs.KeyboardAction.Load1,
      const Key("F1", 112, false, false, false, false)),
  const CsKeyInfo("Install from slot #2", Cs.KeyboardAction.Load2,
      const Key("F2", 113, false, false, false, false)),
  const CsKeyInfo("Install from slot #3", Cs.KeyboardAction.Load3,
      const Key("F3", 114, false, false, false, false)),
  const CsKeyInfo("Install from slot #4", Cs.KeyboardAction.Load4,
      const Key("F4", 115, false, false, false, false)),
  const CsKeyInfo("Extract to slot #1", Cs.KeyboardAction.Save1,
      const Key("F5", 116, false, false, false, false)),
  const CsKeyInfo("Extract to slot #2", Cs.KeyboardAction.Save2,
      const Key("F6", 117, false, false, false, false)),
  const CsKeyInfo("Extract to slot #3", Cs.KeyboardAction.Save3,
      const Key("F7", 118, false, false, false, false)),
  const CsKeyInfo("Extract to slot #4", Cs.KeyboardAction.Save4,
      const Key("F8", 119, false, false, false, false)),
];
