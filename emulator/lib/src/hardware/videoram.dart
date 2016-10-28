// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   videoram.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/28 17:25:24 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;
import "package:emulator/src/video/tile.dart";
import "package:emulator/src/video/tileinfo.dart";

const _TILE_PER_BANK = 0x180;
const _TILE_PER_MAP = 0x400;

class VideoRam extends Ser.RecursivelySerializable {

  List<Tile> _tileData = new List<Tile>(2 * _TILE_PER_BANK);
  Uint8List _mapTileID = new Uint8List(2 * _TILE_PER_MAP);
  List<TileInfo> _mapTileInfo = new List<TileInfo>(2 * _TILE_PER_MAP);

  /* API *********************************************************************/
  void reset() {
    for (int i = 0; i < 2 * _TILE_PER_BANK; ++i) {
      _tileData[i] = new Tile();
    }
    for (int i = 0; i < 2 * _TILE_PER_MAP; ++i) {
      _mapTileID[i] = 0;
      _mapTileInfo[i] = new TileInfo();
    }
  }

  int getTileID(int tileX, int tileY, int tileMapID) {
    assert (tileX >= 0 && tileX <= 32, 'getTileID: invalid tileX');
    assert (tileY >= 0 && tileY <= 32, 'getTileID: invalid tileY');
    assert (tileMapID & ~0x1 == 0, 'getTileID: invalid tileMapID');
    return _mapTileID[tileMapID * _TILE_PER_MAP + tileY * 32 + tileX];
  }

  TileInfo getTileInfo(int tileX, int tileY, int tileMapID) {
    assert (tileX >= 0 && tileX <= 32, 'getTileInfo: invalid tileX');
    assert (tileY >= 0 && tileY <= 32, 'getTileInfo: invalid tileY');
    assert (tileMapID & ~0x1 == 0, 'getTileInfo: invalid tileMapID');
    return _mapTileInfo[tileMapID * _TILE_PER_MAP + tileY * 32 + tileX];
  }

  Tile getTile(int tileID, int bankID, int dataSelectID) {
    assert (tileID & ~0xFF == 0, 'getTile: invalid tileID');
    assert (bankID & ~0x1 == 0, 'getTile: invalid bankID');
    assert (dataSelectID & ~0x1 == 0, 'getTile: invalid dataSelectID');
    if (dataSelectID == 0)
      tileID = 0x100 + tileID.toSigned(8) ;
    return _tileData[bankID * _TILE_PER_BANK + tileID];
  }

  /***** Getters ***************************************************************/
  int pull8_TileData(int addr, int bankID) {
    assert(addr >= 0 && addr < 0x1800, 'pull8_TileData: addr not valid $addr');
    assert(bankID & ~0x1 == 0, 'pull8_TileData: bankID not valid $bankID');
    final int tileNo = addr ~/ 16;
    final int line = addr % 16;
    return _tileData[bankID * _TILE_PER_MAP + tileNo][line];
  }

  int pull8_TileID(int addr) {
    assert(addr & ~0x7FF == 0, 'pull8_TileID: addr not valid $addr');
    return _mapTileID[addr];
  }

  int pull8_TileInfo(int addr) {
    assert(addr & ~0x7FF == 0, 'pull8_TileInfo: addr not valid $addr');
    return _mapTileInfo[addr].value;
  }

  /***** Setters **************************************************************/
  void push8_TileData(int addr, int bankID, int v) {
    assert(addr >= 0 && addr < 0x1800, 'push8_TileData: addr not valid $addr');
    assert(bankID & ~0x1 == 0, 'push8_TileData: bankID not valid $bankID');
    final int tileNo = addr ~/ 16;
    final int line = addr % 16;
    _tileData[bankID * _TILE_PER_MAP + tileNo][line] = v;
    return ;
  }

  void push8_TileID(int addr, int v) {
    assert(addr >= 0 && addr < 0x800, 'push8_TileID: addr not valid $addr');
    _mapTileID[addr] = v;
    return ;
  }

  void push8_TileInfo(int addr, int v) {
    assert(addr >= 0 && addr < 0x800, 'push8_TileInfo: addr not valid $addr');
    _mapTileInfo[addr].value = v;
    return ;
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions sync* {
    yield* _tileData;
    yield* _mapTileInfo;
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('_mapTileID', () => new Uint8List.fromList(_mapTileID), (v) {
            _mapTileID = new Uint8List.fromList(v);
          }),
    ];
  }

}
