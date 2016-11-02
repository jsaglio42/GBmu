// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   store_mappings.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 16:57:42 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 20:08:51 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class StoreMappings {

  // ATTRIBUTES ************************************************************* **
  Map<Key, KeyMap> _claimerOfKey = <Key, KeyMap>{};
  Map<KeyMap, Key> _keyOfClaimer = <KeyMap, Key>{};

  // PUBLIC ***************************************************************** **
  bool isClaimed(Key k) => _claimerOfKey[k] != null;
  KeyMap getClaimerOpt(Key k) => _claimerOfKey[k];

  bool isClaiming(KeyMap m) => _keyOfClaimer[m] != null;
  Key getClaimedOpt(KeyMap m) => _keyOfClaimer[m];

  void updateClaim(KeyMap m, Key kOpt) {
    assert(kOpt == null || _claimerOfKey[kOpt] == null);

    Key prevClaim = _keyOfClaimer[m];

    if (prevClaim != null) {
      _claimerOfKey.remove(prevClaim);
      _keyOfClaimer.remove(m);
    }
    if (kOpt != null) {
      _claimerOfKey[kOpt] = m;
      _keyOfClaimer[m] = kOpt;
    }
  }

}
