FROM google/dart

WORKDIR /app
ADD . /app

# ADD pubspec.* /app/
# RUN pub get
# RUN pub get --offline

CMD ["bash"]
# ENTRYPOINT ["/usr/bin/dart", "main.dart"]