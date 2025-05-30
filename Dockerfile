# Base image
FROM docker.io/library/archlinux:multilib-devel

# Install dependencies
RUN pacman -Syu --needed --noconfirm pacman-contrib git openssh

# Setup user
ENV BUILDER_HOME=/home/builder
RUN useradd -m builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
WORKDIR $BUILDER_HOME
USER builder

# Install paru
RUN git clone https://aur.archlinux.org/paru-bin.git
RUN cd paru-bin && makepkg -si --noconfirm

# Copy files
COPY LICENSE README.md /
COPY entrypoint.sh /entrypoint.sh
COPY ssh_config $BUILDER_HOME/.ssh/config

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
