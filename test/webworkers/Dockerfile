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
RUN apt-get -y install ack-grep tree curl

# RUN 	rm -f						/etc/nginx/nginx.conf
# ADD		./conf/nginx.conf			/etc/nginx/nginx.conf

WORKDIR /app
# ADD 	.	/app
# RUN 	pub get
# RUN		pub get --offline
# RUN		pub build

# CMD service nginx start && bash
# RUN mkdir /app

EXPOSE 80

## docker build -t img_testww .
## docker run --rm --name=c_testww -it -p 80:80 -v `pwd -P`:/app img_testww bash
## docker run --rm --name=c_testww -t -i -p 80:80 img_testww
