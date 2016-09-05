// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   dom_state.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/05 14:49:03 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/05 18:42:18 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// enum BankStatus {
//   Empty,
//   NonEmpty,
// }

// enum CartBankStatus {
// }

// enum ChipBankStatus {
//   Empty,
//   NonEmpty,
// }

// enum GBCartSocketStatus {
//   Empty,
//   NonEmpty,
// }

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
