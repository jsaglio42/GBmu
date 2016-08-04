# FROM google/dart

# WORKDIR /app
# ADD . /app

# ADD pubspec.* /app/


# CMD ["bash"]
# ENTRYPOINT ["/usr/bin/dart", "main.dart"]

###########################################################

FROM google/dart

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install\
	nginx

WORKDIR /usr/share/nginx/html/
RUN 	rm -rf				/usr/share/nginx/html/*
ADD 	./tuto/1-skeleton	/usr/share/nginx/html/
RUN 	pub get
RUN		pub get --offline

CMD service nginx start && bash

EXPOSE	80