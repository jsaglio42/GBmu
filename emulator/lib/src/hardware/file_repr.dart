// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   file_repr.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/09 12:48:23 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/26 20:29:13 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of gbmu_data;

/* Interface for classes representing files (Ram, Rom, Ss) */
abstract class FileRepr {

  // ABSTRACT *************************************************************** **
  V.Component get type;
  String get fileName;
  dynamic get rawData;
  Map<String, dynamic> get terseData;

  dynamic serialize() =>
    <String, dynamic>{
      'data': this.rawData,
      'fileName': this.fileName,
    };

  // STATIC ***************************************************************** **
  static String ramNameOfRomName(String n) {
    final int i = n.length;

    return n.replaceRange(i - ROM_EXTENSION.length, null, RAM_EXTENSION);
  }

  static String ssNameOfRomName(String n) {
    final int i = n.length;

    return n.replaceRange(i - ROM_EXTENSION.length, null, SS_EXTENSION);
  }

}

/* Specialization of FileRepr for AData classes (Ram, Rom) */
abstract class FileReprData implements AData, FileRepr {

  // ATTRIBUTES ************************************************************* **
  String _filename;

  // LIBRARY PUBLIC ********************************************************* **
  void _frd_init(String filename) {
    _filename = filename;
  }

  // FROM FILEREPR ********************************************************** **
  V.Component get type; // Abstract
  String get fileName => _filename;
  Map<String, dynamic> get terseData; // Abstract

  // Used by WorkerEmu to push data to indexedDb
  // Used by DOM to save data to file
  dynamic get rawData => _data;

}
