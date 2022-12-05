FROM smartxworks/virtink-container-disk-base

COPY disk/out /tmp/

RUN cp /tmp/$(uname -m)/disk.img /disk && rm -rf /tmp
