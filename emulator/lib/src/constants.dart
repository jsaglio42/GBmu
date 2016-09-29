// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   constants.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 15:16:09 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 10:46:20 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

final double MICROSECONDS_PER_SECOND_DOUBLE =
  Duration.MICROSECONDS_PER_SECOND.toDouble();
final int MAX_INT_LOLDART = 9007199254740992;

// Number should be close to (GB_CPU_FREQ_INT / EMULATION_PER_SEC_INT)
const int MAXIMUM_CLOCK_PER_EXEC_INT = 100000;

const int GB_FRAME_PER_CLOCK_INT = 70000; // clock
final double GB_FRAME_PER_CLOCK_DOUBLE = GB_FRAME_PER_CLOCK_INT.toDouble();

const int GB_CPU_FREQ_INT = 4194304; // clock / second
const int EMULATION_PER_SEC_INT = 60; // emulation /second
const int DEBUG_PER_SEC_INT = 3; // debug / second
const int FRAME_PER_SEC_INT = 60; // frame / second
const int SPEEDPOLL_PER_SEC_INT = 1; // call / sec

final double GB_CPU_FREQ_DOUBLE = GB_CPU_FREQ_INT.toDouble();
final double EMULATION_PER_SEC_DOUBLE = EMULATION_PER_SEC_INT.toDouble();
final double DEBUG_PER_SEC_DOUBLE = DEBUG_PER_SEC_INT.toDouble();
final double FRAME_PER_SEC_DOUBLE = FRAME_PER_SEC_INT.toDouble();
final double SPEEDPOLL_PER_SEC_DOUBLE = SPEEDPOLL_PER_SEC_INT.toDouble();

final double EMULATION_PERIOD_DOUBLE = 1.0 / EMULATION_PER_SEC_DOUBLE;
final double DEBUG_PERIOD_DOUBLE = 1.0 / DEBUG_PER_SEC_DOUBLE;
final double FRAME_PERIOD_DOUBLE = 1.0 / FRAME_PER_SEC_DOUBLE;
final double SPEEDPOLL_PERIOD_DOUBLE = 1.0 / SPEEDPOLL_PER_SEC_DOUBLE;

// With 60 EMU_PER_SEC, 0.002% Error on reschedule due to `.round()`
final Duration EMULATION_PERIOD_DURATION = new Duration(microseconds:
    (EMULATION_PERIOD_DOUBLE * MICROSECONDS_PER_SECOND_DOUBLE).round());
final Duration DEBUG_PERIOD_DURATION = new Duration(microseconds:
    (DEBUG_PERIOD_DOUBLE * MICROSECONDS_PER_SECOND_DOUBLE).round());
final Duration FRAME_PERIOD_DURATION = new Duration(microseconds:
    (FRAME_PERIOD_DOUBLE * MICROSECONDS_PER_SECOND_DOUBLE).round());
final Duration SPEEDPOLL_PERIOD_DURATION = new Duration(microseconds:
    (SPEEDPOLL_PERIOD_DOUBLE * MICROSECONDS_PER_SECOND_DOUBLE).round());

final Duration EMULATION_START_DELAY = new Duration(milliseconds: 100);

/* Memory Constant */
const int TAIL_RAM_LAST = 0xFFFF;
const int TAIL_RAM_FIRST = 0xFE00;
const int TAIL_RAM_SIZE = TAIL_RAM_LAST - TAIL_RAM_FIRST + 1;

const int FORBIDDEN_MEM_LAST = TAIL_RAM_FIRST - 1;
const int FORBIDDEN_MEM_FIRST = 0xE000;

const int INTERNAL_RAM_LAST = FORBIDDEN_MEM_FIRST - 1;
const int INTERNAL_RAM_FIRST = 0xC000;
const int INTERNAL_RAM_SIZE = INTERNAL_RAM_LAST - INTERNAL_RAM_FIRST + 1;

const int CARTRIDGE_RAM_LAST = INTERNAL_RAM_FIRST - 1;
const int CARTRIDGE_RAM_FIRST = 0xA000;
const int CARTRIDGE_RAM_SIZE = CARTRIDGE_RAM_LAST - CARTRIDGE_RAM_FIRST + 1;

const int VIDEO_RAM_LAST = INTERNAL_RAM_FIRST - 1;
const int VIDEO_RAM_FIRST = 0x8000;
const int VIDEO_RAM_SIZE = VIDEO_RAM_LAST - VIDEO_RAM_FIRST + 1;

const int CARTRIDGE_ROM_LAST = VIDEO_RAM_FIRST - 1;
const int CARTRIDGE_ROM_FIRST = 0x0000;
const int CARTRIDGE_ROM_SIZE = CARTRIDGE_ROM_LAST - CARTRIDGE_ROM_FIRST + 1;


/* Memory Constant */
const int LCD_WIDTH = 160;
const int LCD_HEIGHT = 140;
const int LCD_DATA_SIZE = LCD_HEIGHT * LCD_WIDTH * 4;
