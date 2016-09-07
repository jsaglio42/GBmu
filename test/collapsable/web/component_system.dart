// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   component_system.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 14:48:01 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/07 14:48:24 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

enum Dragging {
  None,

  Cart,
    /* Grabbable ->
     *   (#CartBank .openCart)
     *   (#GBCartSocket.non-empty)
     * Droppable ->
     *   (#CartBank)
     *   (#GBCartSocket.empty)
     */

  Ram,
    /* Grabbable ->
     *   (#CartBank .openCart .cart-ram-socket.non-empty)
     *   (#ChipBank .ram)
     * Droppable ->
     *   (#CartBank .openCart .cart-ram-socket.empty)
     *   (#ChipBank)
     */

  Ss,
    /* Grabbable ->
     *   (#CartBank .openCart .cart-ss-socket.non-empty)
     *   (#ChipBank .ss)
     * Droppable ->
     *   (#CartBank .openCart .cart-ss-socket.empty)
     *   (#ChipBank)
     */

  File,
    /* Droppable ->
     *   (#CartBank)
     *   (#ChipBank)
     * Grabbable ->
     *   (Out of browser)
     */
}

enum ChipType {
  Ram,
  Ss,
}

enum Location {
  DetachedChipBank,
  CartBank,
  GameBoy,
}

enum CartLocation {
  CartBank,
  GameBoy,
}
