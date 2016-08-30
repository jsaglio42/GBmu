#******************************************************************************#
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/08/04 15:22:57 by ngoguey           #+#    #+#              #
#    Updated: 2016/08/04 15:22:57 by ngoguey          ###   ########.fr        #
#                                                                              #
#******************************************************************************#

# FROM google/dart-runtime-base
FROM debian:latest
RUN apt-get update
RUN apt-get -y install build-essential
RUN apt-get -y install sudo curl netcat
RUN sudo apt-get -y install apt-transport-https

# INSTRUCTIONS FROM DART WEBSITE

# Get the Google Linux package signing key.
RUN sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'

# Set up the location of the stable repository.
RUN sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'

RUN sudo apt-get update

# Before running this command, follow the instructions in
# "Set up for the stable channel".
RUN sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_unstable.list > /etc/apt/sources.list.d/dart_unstable.list'

RUN apt-get -y install dart
ENV PATH "/usr/lib/dart/bin/:"${PATH}

WORKDIR /web
ADD . /web
RUN	cd 1-skeleton;	pub get
RUN	cd 1-skeleton;	pub build

CMD bash
EXPOSE 8080

# docker build -t ng2img .
# docker run -it -p 8080:8080 --name=ng2cont --rm ng2img
