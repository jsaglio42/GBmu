// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   save_state.dart                                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/09 13:55:31 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/27 16:00:22 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of gbmu_data;

// Save State *************************************************************** **
class Ss extends Object
  with FileRepr {

  // ATTRIBUTES ************************************************************* **
  final String _fileName;
  final Map _data;

  // CONSTRUCTION *********************************************************** **
  // Only called once in DOM, when an external file is loaded
  Ss.ofFile(String fileName, Uint8List data)
    : _fileName = fileName
    , _data = JSON.decode(ASCII.decode(data)) {
    Ft.log('Ss', 'ctor.ofFile', [this.fileName, this.terseData]);
  }

  // Only called from Emulator, on emulation start request, with data from Idb
  Ss.unserialize(Map<String, dynamic> serialization)
    : _fileName = serialization['fileName']
    , _data = serialization['data'] {
    Ft.log('Ss', 'ctor.unserialize', [this.fileName, this.terseData]);
  }

  // Only called from Emulator, on gameboy snapshot required
  Ss.ofGameBoy(GameBoy.GameBoy gb)
    : _fileName = FileRepr.ssNameOfRomName(gb.c.rom.fileName)
    , _data = gb.recSerialize() {
    _data['__romGlobalChecksum'] =
      gb.c.rom.pullHeaderValue(RomHeaderField.Global_Checksum);
    Ft.log('Ss', 'ctor.ofGameBoy', [this.fileName, this.terseData]);
  }

  // Only called from DOM, when an extraction is requested
  Ss.emptyDetail(String romName, int romGlobalChecksum)
    : _fileName = FileRepr.ssNameOfRomName(romName)
    , _data = {'__romGlobalChecksum': romGlobalChecksum} {
    Ft.log('Ss', 'ctor.emptyDetail', [this.fileName, this.terseData]);
  }

  // FROM FILEREPR ********************************************************** **
  V.Component get type => V.Ss.v;
  String get fileName => _fileName;
  Map<String, dynamic> get terseData => <String, dynamic>{
    'romGlobalChecksum': this.romGlobalChecksum,
  };


  // PUBLIC ***************************************************************** **
  int get romGlobalChecksum => _data['__romGlobalChecksum'];

  dynamic get rawData => _data;
}
