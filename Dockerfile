FROM i386/alpine:3.12.1

# Set your prefered Language
#ENV SETLANGUAGE=en_US.UTF-8
ENV SETLANGUAGE=de_DE.UTF-8

# Install required packages
RUN apk --update --no-cache add wine xvfb x11vnc openbox samba-winbind-clients \
    font-misc-misc ttf-dejavu ttf-font-awesome

# Install Languages
ENV MUSL_LOCPATH="/usr/share/i18n/locales/musl"
RUN apk --no-cache add libintl && \
    apk --no-cache --virtual .locale_build add cmake make musl-dev gcc gettext-dev git && \
    git clone https://gitlab.com/rilian-la-te/musl-locales.git && \
    cd musl-locales && cmake -DLOCALE_PROFILE=OFF -DCMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install && \
    cd .. && rm -r musl-locales && \
    apk del .locale_build

# Set Language
ENV LC_ALL $SETLANGUAGE

# Disable openbox right click menu
COPY rc.xml /root/.config/openbox/rc.xml

# Configure the virtual display port
ENV DISPLAY :0

# Expose the vnc port
EXPOSE 5900

# Configure the wine prefix location
RUN mkdir /wine
ENV WINEPREFIX /wine

# Disable wine debug messages
ENV WINEDEBUG -all

# Configure wine to run without mono or gecko as they are not required
ENV WINEDLLOVERRIDES mscoree,mshtml=

# Set the wine computer name
ENV COMPUTER_NAME bz-docker

# Create the data Directory
RUN mkdir /data

# Bugfix for fontconfig invalid cache files spam - BUG?!
RUN rm -R /var/cache/fontconfig && ln -s /dev/null /var/cache/fontconfig

# Copy the start script to the container
COPY start.sh /start.sh

# Set the start script as entrypoint
ENTRYPOINT ./start.sh
