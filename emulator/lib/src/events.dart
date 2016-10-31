// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   events.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/18 11:11:29 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/29 20:31:09 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

class EventIdb {

  final String idb;
  final String store;
  final int key;

  EventIdb(this.idb, this.store, this.key);

}

class RequestEmuStart {

  final String idb;
  final String romStore;
  final String ramStore;

  final int romKey;
  final int ramKeyOpt;

  RequestEmuStart({
    this.idb, this.romStore, this.ramStore, this.romKey, this.ramKeyOpt});

}
