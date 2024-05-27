ARG VERSION
FROM alpine:${VERSION}
RUN adduser -D builder \
	&& echo 'builder  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
	&& apk add --no-cache \
	alpine-sdk alpine-conf syslinux xorriso squashfs-tools \
	grub grub-efi sudo mtools dosfstools grub-efi

USER builder
RUN cd /home/builder && git clone --depth=1 https://gitlab.alpinelinux.org/alpine/aports.git
RUN echo -e "\n" | abuild-keygen -i -a && sudo apk upgrade -U -a
COPY --chmod=0755 create-iso /home/builder/aports/scripts/create-iso
WORKDIR /home/builder/aports/scripts
CMD ["./create-iso"]
