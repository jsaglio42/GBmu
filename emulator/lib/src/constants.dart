// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   constants.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 15:16:09 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/29 18:08:07 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const double MICROSECONDS_PER_SECOND_DOUBLE =
  Duration.MICROSECONDS_PER_SECOND / 1.0;
const int MAX_INT_LOLDART = 9007199254740992;

// Number should be close to (GB_CPU_FREQ_INT / EMULATION_PER_SEC_INT)
const int MAXIMUM_CLOCK_PER_EXEC_INT = 100000;

const int GB_CLOCK_PER_LINE_INT = 456; // clock
const double GB_CLOCK_PER_LINE_DOUBLE = GB_CLOCK_PER_LINE_INT / 1.0;

const int GB_CLOCK_PER_FRAME_INT = 70224; // clock
const double GB_CLOCK_PER_FRAME_DOUBLE = GB_CLOCK_PER_FRAME_INT / 1.0;

const int GB_CPU_FREQ_INT = 4194304; // clock / second
// const int EMULATION_PER_SEC_INT = 60; // emulation /second
const int DEBUG_PER_SEC_INT = 3; // debug / second
// const int FRAME_PER_SEC_INT = 60; // frame / second
const int SPEEDPOLL_PER_SEC_INT = 1; // call / sec

const double GB_CPU_FREQ_DOUBLE = GB_CPU_FREQ_INT / 1.0;
// const double EMULATION_PER_SEC_DOUBLE = EMULATION_PER_SEC_INT / 1.0;
const double DEBUG_PER_SEC_DOUBLE = DEBUG_PER_SEC_INT / 1.0;
// const double FRAME_PER_SEC_DOUBLE = FRAME_PER_SEC_INT / 1.0;
const double SPEEDPOLL_PER_SEC_DOUBLE = SPEEDPOLL_PER_SEC_INT / 1.0;

// const double EMULATION_PERIOD_DOUBLE = 1.0 / EMULATION_PER_SEC_DOUBLE;
const double DEBUG_PERIOD_DOUBLE = 1.0 / DEBUG_PER_SEC_DOUBLE;
// const double FRAME_PERIOD_DOUBLE = 1.0 / FRAME_PER_SEC_DOUBLE;
const double SPEEDPOLL_PERIOD_DOUBLE = 1.0 / SPEEDPOLL_PER_SEC_DOUBLE;

// With 60 EMU_PER_SEC, 0.002% Error on reschedule due to rounding
// const Duration EMULATION_PERIOD_DURATION = const Duration(microseconds:
    // (EMULATION_PERIOD_DOUBLE * MICROSECONDS_PER_SECOND_DOUBLE + 0.5) ~/ 1);
const Duration DEBUG_PERIOD_DURATION = const Duration(microseconds:
    (DEBUG_PERIOD_DOUBLE * MICROSECONDS_PER_SECOND_DOUBLE + 0.5) ~/ 1);
// const Duration FRAME_PERIOD_DURATION = const Duration(microseconds:
    // (FRAME_PERIOD_DOUBLE * MICROSECONDS_PER_SECOND_DOUBLE + 0.5) ~/ 1);
const Duration SPEEDPOLL_PERIOD_DURATION = const Duration(microseconds:
    (SPEEDPOLL_PERIOD_DOUBLE * MICROSECONDS_PER_SECOND_DOUBLE + 0.5) ~/ 1);

const Duration EMULATION_START_DELAY = const Duration(milliseconds: 100);
const Duration EMULATION_RESCHEDULE_MIN_DELAY = const Duration(milliseconds: 3);

/* Memory Mapping */
const int TAIL_RAM_LAST = 0xFFFF;
const int TAIL_RAM_FIRST = 0xFF00;
const int TAIL_RAM_SIZE = TAIL_RAM_LAST - TAIL_RAM_FIRST + 1;

const int FORBIDDEN_LAST = 0xFEFF;
const int FORBIDDEN_FIRST = 0xFEA0;

const int OAM_LAST = 0xFE9F;
const int OAM_FIRST = 0xFE00;

const int ECHO_RAM_LAST = 0xFDFF;
const int ECHO_RAM_FIRST = 0xE000;
const int ECHO_RAM_OFFSET = ECHO_RAM_FIRST - INTERNAL_RAM_FIRST;

const int INTERNAL_RAM_LAST = 0xDFFF;
const int INTERNAL_RAM_FIRST = 0xC000;
const int IRAM_BANK_SIZE = 0x1000;
const int IRAM_BANK_COUNT = 8;

const int CARTRIDGE_RAM_LAST = 0xBFFF;
const int CARTRIDGE_RAM_FIRST = 0xA000;
const int CRAM_BANK_SIZE = 0x2000;

const int VIDEO_RAM_LAST = 0x9FFF;
const int VIDEO_RAM_FIRST = 0x8000;
const int VIDEO_RAM_SIZE = VIDEO_RAM_LAST - VIDEO_RAM_FIRST + 1;

const int CARTRIDGE_ROM_LAST = 0x7FFF;
const int CARTRIDGE_ROM_FIRST = 0x0000;
const int CROM_BANK_SIZE = 0x4000;


/* LCD Constant */
const int LCD_WIDTH = 160;
const int LCD_HEIGHT = 144;
const int LCD_SIZE = LCD_HEIGHT * LCD_WIDTH;
const int LCD_DATA_SIZE = LCD_SIZE * 4;

/* LCD Mode constants */
const int CLOCK_PER_OAM_ACCESS = 80;
const int CLOCK_PER_VRAM_ACCESS = 172;
const int CLOCK_PER_HBLANK = 204;
const int CLOCK_PER_LINE = CLOCK_PER_OAM_ACCESS
  + CLOCK_PER_VRAM_ACCESS
  + CLOCK_PER_HBLANK;

const int VBLANK_THRESHOLD = LCD_HEIGHT;
const int FRAME_THRESHOLD = VBLANK_THRESHOLD + 10;

/* File extensions */
const String ROM_EXTENSION = ".gb";
const String RAM_EXTENSION = ".save";
const String SS_EXTENSION = ".ss";
