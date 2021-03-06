
##### Goals
- [X] Create a Game Boy emulator using any language
- [X] Implement the CPU, LCD, joypad
- [X] Have a minimalistic GUI (load / play / pause)
- [ ] Run cartridges of type `MBC{1,2,3,5}`
- [X] Handle cartridges saves
- [ ] Handle both the Game Boy (DMG) and the Color Game Boy (CGB)
- [X] A debugger observing the CPU and able to operate frame by frame
- [X] Emulate at speed x1 without blocking the gui
- [ ] Create an application deployable with a `.app`

##### Recommended bonuses
- [ ] Sound using a library
- [ ] BIOS
- [ ] Force DMG/CGB emulation on compatible cartridges
- [X] Save states
- [X] Advanced GUI

##### Our work
- [ ] todo

<BR>

---

### Install
```sh
# get dart first
pub get
pub serve
open 'http://localhost:8080/'
```

<BR>

---

### Useful links:
##### Ressources
```sh
curl -O https://projects.intra.42.fr/uploads/document/document/323/ressources.tgz && tar -zxf ressources.tgz && mv ressources/roms .
```

##### Gameboy / Emulation
- Z80 decode table
  - http://www.z80.info/decoding.htm
- Short-Blog: Writing a Game Boy emulator, Cinoop
  - https://cturt.github.io/cinoop.html
- 10 chapters blog: GameBoy Emulation in JavaScript
  - http://imrannazar.com/GameBoy-Emulation-in-JavaScript
- OChip8: Js implementation of Chip8
  - http://ochip8.com/
- How To Write a Computer Emulator
  - http://fms.komkon.org/EMUL8/HOWTO.html
- Tutorial on DB, NES, SNES emulation
  - http://www.codeslinger.co.uk/index.html
- Gameboy CPU manual
  - http://marc.rawer.de/Gameboy/Docs/GBCPUman.pdf
- Pan Documents
  - http://bgb.bircd.org/pandocs.htm
- Memory Bank Controller
  - http://gbdev.gg8.se/wiki/articles/Memory_Bank_Controllers
- Gameboy programming manual
  - http://www.chrisantonellis.com/files/gameboy/gb-programming-manual.pdf

##### Dart
- Dart
  - https://www.dartlang.org/guides/language/language-tour

<BR>

---

![Screenshot](./res/screenshot2.png)
