# Install

<BR>
```sh
pub get
pub serve
```
- http://localhost:8080/

# Todos

- Deal with optional/XYZorNull in a consistent way. (I would go for the use of null/notnull with an explicit name, maybe not XYZorNull but xyzOpt)
- Have a textbox in the dom to display important messages to the user (not in debug console), for example: "Rom is not valid/not supported", "A rom is not loaded ...." ...
- Talk about the full asynchroneous approach for debugger, right now, in high speed, run one inst take as long as run one sec which seems weird. Running one inst feels like running two (colors in debugger). Solution -> Maybe force the update on browserside when a routine is done

# Useful links:

### Ressources
```sh
curl -O https://projects.intra.42.fr/uploads/document/document/323/ressources.tgz
```

### Gameboy / Emulation

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
