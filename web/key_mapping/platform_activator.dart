// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_activator.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 17:22:07 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 20:13:09 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class PlatformActivator {

  // ATTRIBUTES ************************************************************* **
  final StoreMappings _sm;

  // CONSTRUCTIONS ********************************************************** **
  PlatformActivator(this._sm);

  // PUBLIC ***************************************************************** **
  bool useKeyPress(Key k) {
    KeyMap claimerOpt = _sm.getClaimerOpt(k);

    if (claimerOpt != null) {
      if (claimerOpt.pressActionOpt != null)
        claimerOpt.pressActionOpt();
      return true;
    }
    else
      return false;
  }

  bool useKeyRelease(Key k) {
    KeyMap claimerOpt = _sm.getClaimerOpt(k);

    if (claimerOpt != null) {
      if (claimerOpt.releaseActionOpt != null)
        claimerOpt.releaseActionOpt();
      return true;
    }
    else
      return false;
  }

}
