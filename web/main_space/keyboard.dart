
/* Keyboard events */

Emulator emu;

void init(Emulator.Emulator emu) {
  emu = emu
  Html.window.onKeyDown
    .listen((keyEvent) => _onKeyDown(emu, keyEvent.keyCode));
  Html.window.onKeyUp
    .listen((keyEvent) => _onKeyUp(emu, keyEvent.keyCode));
  return ;
}

Map<JoypadKey, bool> _keyState = <JoypadKey, bool>{
  JoypadKey.A : false,
  JoypadKey.B : false,
  JoypadKey.Select : false,
  JoypadKey.Start : false,
  JoypadKey.Right : false,
  JoypadKey.Left : false,
  JoypadKey.Up : false,
  JoypadKey.Down : false
};

JoypadKey _getJoypadKey(int JSJoypadKey) {
  switch (JSJoypadKey) {
    case (75) : return JoypadKey.A;
    case (76) : return JoypadKey.B;
    case (16) : return JoypadKey.Select;
    case (13) : return JoypadKey.Start;
    case (68) : return JoypadKey.Right;
    case (65) : return JoypadKey.Left;
    case (87) : return JoypadKey.Up;
    case (83) : return JoypadKey.Down;
    default : return null;
  }
}

void _onKeyDown(Emulator.Emulator emu, int JSJoypadKey){
  JoypadKey key = _getJoypadKey(JSJoypadKey);
  if (key == null || _keyState[key] == true)
    return ;
  _keyState[key] = !_keyState[key]
  emu.send('KeyDownEvent', key);
  return ;
}

void _onKeyUp(Emulator.Emulator emu, int JSJoypadKey){
  JoypadKey key = _getJoypadKey(JSJoypadKey);
  if (key == null || _keyState[key] == false)
    return ;
  _keyState[key] = !_keyState[key]
  emu.send('KeyUpEvent', key);
  return ;
}
