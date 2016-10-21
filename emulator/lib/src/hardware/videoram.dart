// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   videoram.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/21 18:57:07 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/video/tile.dart";
import "package:emulator/src/video/tileinfo.dart";

const _TILE_PER_BANK = 0x180;
const _TILE_PER_MAP = 0x400;

class VideoRam {

  final List<Tile> _tileData = new List<Tile>(2 * _TILE_PER_BANK);
  final Uint8List _mapTileID = new Uint8List(2 * _TILE_PER_MAP);
  final List<TileInfo> _mapTileInfo = new List<TileInfo>(2 * _TILE_PER_MAP);

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
    tileID += (1 - dataSelectID) * (tileID.toSigned(8) + 0x100);
    return _tileData[bankID * _TILE_PER_BANK + tileID];
  }

  /***** Getters ***************************************************************/
  int pull8_TileData(int offset, int bankID) {
    assert(offset >= 0 && offset < 0x1800, 'pull8_TileData: offset not valid $offset');
    assert(bankID & ~0x1 == 0, 'pull8_TileData: bankID not valid $bankID');
    final int tileNo = offset ~/ 16;
    final int line = offset % 16;
    return _tileData[bankID * _TILE_PER_MAP + tileNo][line];
  }

  int pull8_TileID(int offset) {
    assert(offset & ~0x7FF == 0, 'pull8_TileID: offset not valid $offset');
    return _mapTileID[offset];
  }

  int pull8_TileInfo(int offset) {
    assert(offset & ~0x7FF == 0, 'pull8_TileInfo: offset not valid $offset');
    return _mapTileInfo[offset].value;
  }

  /***** Setters **************************************************************/
  void push8_TileData(int offset, int bankID, int v) {
    assert(offset >= 0 && offset < 0x1800, 'push8_TileData: offset not valid $offset');
    assert(bankID & ~0x1 == 0, 'push8_TileData: bankID not valid $bankID');
    final int tileNo = offset ~/ 16;
    final int line = offset % 16;
    _tileData[bankID * _TILE_PER_MAP + tileNo][line] = v;
    return ;
  }

  void push8_TileID(int offset, int v) {
    assert(offset >= 0 && offset < 0x800, 'push8_TileID: offset not valid $offset');
    _mapTileID[offset] = v;
    return ;
  }

  void push8_TileInfo(int offset, int v) {
    assert(offset >= 0 && offset < 0x800, 'push8_TileInfo: offset not valid $offset');
    _mapTileInfo[offset].value = v;
    return ;
  }

}
