# Use the Ubuntu base image
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y ca-certificates openssh-client

# Set the working directory to /home
WORKDIR /home

# Add the hello-world.txt file to the current working directory (/home)
ADD hello-world.txt hello-world.txt

CMD ["sleep", "3600"]