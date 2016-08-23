// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/20 13:58:56 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 13:39:16 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;

Iterable<List<Html.TableCellElement>> iterTableRows(Html.TableElement tab) sync*
{
  final List<Html.TableRowElement> rows = tab.rows;
  assert(rows != null);
  final Iterator<Html.TableRowElement> it = rows.iterator;

  while (it.moveNext())
    yield it.current.cells;
  return ;
}