# FROM google/dart

# WORKDIR /app
# ADD . /app

# ADD pubspec.* /app/


# CMD ["bash"]
# ENTRYPOINT ["/usr/bin/dart", "main.dart"]

###########################################################

FROM google/dart

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install build-essential sudo

RUN apt-get -y install vim nginx

RUN 	rm -f						/etc/nginx/nginx.conf
ADD		./conf/nginx.conf			/etc/nginx/nginx.conf

WORKDIR /app
ADD 	./tuto/5-piratenameservice	/app
RUN 	pub get
RUN		pub get --offline
RUN		pub build


CMD service nginx start && bash

EXPOSE	80