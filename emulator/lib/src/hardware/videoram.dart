// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   videoram.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 20:35:56 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/video/tile.dart";
import "package:emulator/src/video/tileinfo.dart";

const TILE_PER_BANK = 384;
const TILE_PER_MAP = 32 * 32;

class VideoRam {

  final List<Tile> _tileData = new List<Tile>();
  final List<int> _tileMap = new List<int>();
  final List<TileInfo> _tileInfoMap = new List<TileInfo>();

  /* API *********************************************************************/
  void reset() {
    _tileData.clear();
    _tileMap.clear();
    _tileInfoMap.clear();
    for (int i; i < 2 * TILE_PER_BANK; ++i) {
      _tileData.add(new Tile());
    }
    for (int i; i < 2 * TILE_PER_MAP; ++i) {
      _tileMap.add(0);
      _tileInfoMap.add(new TileInfo());
    }
  }

  int getTileID(int tileX, int tileY, int tileMapID) {
    assert (tileX >= 0 && tileX <= 32, 'getTileID: invalid tileX');
    assert (tileY >= 0 && tileY <= 32, 'getTileID: invalid tileY');
    assert (tileMapID & ~0x1 == 0, 'getTileID: invalid tileMapID');
    return _tileMap[tileMapID * TILE_PER_MAP + tileY * 32 + tileX];
  }

  TileInfo getTileInfo(int tileX, int tileY, int tileMapID) {
    assert (tileX >= 0 && tileX <= 32, 'getTileInfo: invalid tileX');
    assert (tileY >= 0 && tileY <= 32, 'getTileInfo: invalid tileY');
    assert (tileMapID & ~0x1 == 0, 'getTileInfo: invalid tileMapID');
    return _tileInfoMap[tileMapID * TILE_PER_MAP + tileY * 32 + tileX];
  }


  Tile getTile(int tileID, int bankID, int dataSelectID) {
    assert (tileID & ~0xFF == 0, 'getTile: invalid tileID');
    assert (bankID & ~0x1 == 0, 'getTile: invalid bankID');
    assert (dataSelectID & ~0x1 == 0, 'getTile: invalid dataSelectID');
    if (dataSelectID == 0)
      tileID = tileID.toSigned(8) + 0x100;
    return _tileData[(1 - dataSelectID) + tileID];
  }

  /***** TO BE IMPLEMENTED ***/
  void push8(int memAddr, int v) {
    return ;
   //  memAddr -= VIDEO_RAM_FIRST;
  	// _data[memAddr] = v;
  }

  int pull8(int memAddr, int bankNo) {
    // memAddr -= VIDEO_RAM_FIRST;
  	// return _data[memAddr];
    return 0x0;
  }

}
