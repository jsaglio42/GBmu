// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tmp_emulator_enums.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 15:48:40 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/27 15:48:45 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

enum RomHeaderField {
  Entry_Point,
  Nintendo_Logo,
  Title,
  Manufacturer_Code,
  CGB_Flag,
  New_Licensee_Code,
  SGB_Flag,
  Cartridge_Type,
  ROM_Size,
  RAM_Size,
  Destination_Code,
  Old_Licensee_Code,
  Mask_ROM_Version_number,
  Header_Checksum,
  Global_Checksum,
}
