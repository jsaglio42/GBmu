// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   constants.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 15:16:09 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/26 12:16:55 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

final double MICROSECONDS_PER_SECOND_DOUBLE =
  Duration.MICROSECONDS_PER_SECOND.toDouble();

// Number should be close to (GB_CPU_FREQ_INT / EMULATION_PER_SEC_INT = 139810)
const int MAXIMUM_CLOCK_PER_EXEC_INT = 100000;

const int GB_FRAME_PER_CLOCK_INT = 70000; // clock
final double GB_FRAME_PER_CLOCK_DOUBLE = GB_FRAME_PER_CLOCK_INT.toDouble();

const int GB_CPU_FREQ_INT = 4194304; // clock / second
const int EMULATION_PER_SEC_INT = 60; // emulation /second
const int DEBUG_PER_SEC_INT = 1; // debug / second
const int FRAME_PER_SEC_INT = 60; // frame / second

final double GB_CPU_FREQ_DOUBLE = GB_CPU_FREQ_INT.toDouble();
final double EMULATION_PER_SEC_DOUBLE = EMULATION_PER_SEC_INT.toDouble();
final double DEBUG_PER_SEC_DOUBLE = DEBUG_PER_SEC_INT.toDouble();
final double FRAME_PER_SEC_DOUBLE = FRAME_PER_SEC_INT.toDouble();

// With 60 EMU_PER_SEC, 0.002% Error on reschedule due to `.round()`
final Duration EMULATION_PERIOD_DURATION = new Duration(
    microseconds: (MICROSECONDS_PER_SECOND_DOUBLE / EMULATION_PER_SEC_DOUBLE).round());
final Duration DEBUG_PERIOD_DURATION = new Duration(
    microseconds: (MICROSECONDS_PER_SECOND_DOUBLE / DEBUG_PER_SEC_DOUBLE).round());
final Duration FRAME_PERIOD_DURATION = new Duration(
    microseconds: (MICROSECONDS_PER_SECOND_DOUBLE / FRAME_PER_SEC_DOUBLE).round());


final Duration EMULATION_START_DELAY = new Duration(milliseconds: 500);

const int WORKING_RAM_BEGIN = 0;
const int WORKING_RAM_LAST = 10;
const int WORKING_RAM_SIZE = WORKING_RAM_LAST - WORKING_RAM_BEGIN + 1;

const int VIDEO_RAM_BEGIN = 0;
const int VIDEO_RAM_LAST = 10;
const int VIDEO_RAM_SIZE = VIDEO_RAM_LAST - VIDEO_RAM_BEGIN + 1;

const int TAIL_RAM_BEGIN = 0xFF00;
const int TAIL_RAM_LAST = 0xFFFF;
const int TAIL_RAM_SIZE = TAIL_RAM_LAST - TAIL_RAM_BEGIN + 1;
