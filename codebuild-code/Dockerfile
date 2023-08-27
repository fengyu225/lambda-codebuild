# Use the Ubuntu base image
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y ca-certificates openssh-client openssh-client

# Add the hello-world.txt file to the container image
ADD hello-world.txt /home/hello-world.txt

CMD ["sleep 3600"]