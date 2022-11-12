FROM i386/alpine:3.12.1

# Set your prefered Language
#ENV SETLANGUAGE=en_US.UTF-8
ENV SETLANGUAGE=de_DE.UTF-8

# Install required packages
RUN apk --update --upgrade --no-cache add wine xvfb x11vnc openbox samba-winbind-clients ttf-dejavu

# Install noVNC
RUN apk --no-cache add bash python3 procps && apk --no-cache --virtual .build-deps add git build-base python3-dev py-pip && \
    # Not needed for this purpose and saves ~100MB # pip install --no-cache-dir numpy && \
    git config --global advice.detachedHead false && git clone https://github.com/novnc/noVNC --branch v1.3.0 /opt/noVNC && \
    git clone https://github.com/novnc/websockify --branch v0.10.0 /opt/noVNC/utils/websockify && \
    apk del .build-deps && \
    rm -R /opt/noVNC/.git* && \
    rm -R /opt/noVNC/utils/websockify/.git* && \
    cp /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    sed -i s"/'autoconnect', false/'autoconnect', 'true'/" /opt/noVNC/app/ui.js

# Install Languages
ENV MUSL_LOCPATH="/usr/share/i18n/locales/musl"
RUN apk --no-cache add libintl && \
    apk --no-cache --virtual .build-deps add cmake make musl-dev gcc gettext-dev git && \
    git clone https://gitlab.com/rilian-la-te/musl-locales.git && \
    cd musl-locales && cmake -DLOCALE_PROFILE=OFF -DCMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install && \
    cd .. && rm -r musl-locales && \
    apk del .build-deps

# Set Language
ENV LC_ALL $SETLANGUAGE

# Disable openbox right click menu
COPY rc.xml /root/.config/openbox/rc.xml

# Configure the virtual display port
ENV DISPLAY :0

# Expose the VNC and noVNC-Web port
EXPOSE 5900 6080

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

# Workaround for fontconfig invalid cache files spam - BUG?!
RUN rm -R /usr/share/fonts/100dpi \
          /usr/share/fonts/75dpi \
          /usr/share/fonts/cyrillic \
          /usr/share/fonts/encodings \
          /usr/share/fonts/misc && \
          rm -R /var/cache/fontconfig && \
          ln -s /dev/null /var/cache/fontconfig

# Copy the start script to the container
COPY start.sh /start.sh

# Set the start script as entrypoint
ENTRYPOINT ./start.sh
