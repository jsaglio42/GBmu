# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    setup.sh                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/08/09 13:18:19 by ngoguey           #+#    #+#              #
#    Updated: 2016/08/09 13:18:48 by ngoguey          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

set -e

rm -f /etc/nginx/nginx.conf
cp ./conf/nginx.conf /etc/nginx/nginx.conf
pub get
service nginx start

# RUN 	pub get
# RUN		pub get --offline
# RUN		pub build

# CMD service nginx start && bash
