FROM i386/alpine:3.12.1

# Install required packages
RUN apk --update --no-cache add xvfb x11vnc openbox samba-winbind-clients 
RUN echo "https://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --no-cache add wine

# Configure the virtual display port
ENV DISPLAY :0

# Expose the vnc port
EXPOSE 5900

# Configure the wine prefix location
RUN mkdir /wine
ENV WINEPREFIX /wine/

# Disable wine debug messages
ENV WINEDEBUG -all

# Configure wine to run without mono or gecko as they are not required
ENV WINEDLLOVERRIDES mscoree,mshtml=

# Set the wine computer name
ENV COMPUTER_NAME bz-docker

# Create the data Directory
RUN mkdir /data

# Copy the start script to the container
COPY start.sh /start.sh

# Set the start script as entrypoint
ENTRYPOINT ./start.sh
