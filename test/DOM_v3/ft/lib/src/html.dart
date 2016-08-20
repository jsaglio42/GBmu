// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/20 13:58:56 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/20 14:32:42 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;

Iterable<List<Html.TableCellElement>> iterTableRows(
    Html.TableElement tab, int offset) sync*
{
  final List<Html.TableRowElement> rows = tab.rows;
  assert(rows != null);
  final Iterator<Html.TableRowElement> it = rows.iterator;

  Html.TableRowElement row = null;

  for (int i = 0; i < offset; i++) {
    if (!it.moveNext())
      assert(false);
  }
  while (it.moveNext()) {
    yield it.current.cells;
  }
  return ;
}