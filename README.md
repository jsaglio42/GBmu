# Install

<BR>
```sh
pub get
pub serve
```
- http://localhost:8080/

# BUG

- Lot of crash when playing with the debugger)
- Debugger seem partly blocked when closed and re-opened

# To DOs: Checks

- Check operands where a signed byte 'e' is added
- Check timer loop if CPU halted or stopped

# To DOs: Features

- Add the different flags in the debugger:
	- ime
	- halt
	- stop
	- joypadState ?
- Reorganise Memory Registers per category (Mode/Port, Interrupt, LCD, Timers ...)
- Add overlay for instructions (display extra info like duration, flag modified ...) ?


# Useful links:

### Ressources
```sh
curl -O https://projects.intra.42.fr/uploads/document/document/323/ressources.tgz
```

### Gameboy / Emulation

<BR>
> Z80 decode table
> - http://www.z80.info/decoding.htm

<BR>
> Short-Blog: Writing a Game Boy emulator, Cinoop
> - https://cturt.github.io/cinoop.html

<BR>
> 10 chapters blog: GameBoy Emulation in JavaScript
> - http://imrannazar.com/GameBoy-Emulation-in-JavaScript

<BR>
> OChip8: Js implementation of Chip8
> - http://ochip8.com/

<BR>
> How To Write a Computer Emulator
> - http://fms.komkon.org/EMUL8/HOWTO.html

<BR>
> Tutorial on DB, NES, SNES emulation
> - http://www.codeslinger.co.uk/index.html

<BR>
> Gameboy CPU manual
> - http://marc.rawer.de/Gameboy/Docs/GBCPUman.pdf

<BR>
> Pan Documents
> - http://bgb.bircd.org/pandocs.htm

<BR>
> Memory Bank Controller
> - http://gbdev.gg8.se/wiki/articles/Memory_Bank_Controllers

<BR>
> Gameboy programming manual
> - http://www.chrisantonellis.com/files/gameboy/gb-programming-manual.pdf

### Dart

<BR>
> Dart
> - https://www.dartlang.org/guides/language/language-tour
