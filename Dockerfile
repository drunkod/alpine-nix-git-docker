FROM alpine:3.21

# Install prerequisites - ADD COREUTILS for GNU cp
RUN apk add --no-cache \
    bash \
    curl \
    shadow \
    sudo \
    xz \
    ca-certificates \
    coreutils

# Create nix build users
RUN addgroup -S nixbld && \
    for i in $(seq 1 10); do adduser -S -G nixbld nixbld$i; done

# Install Nix in single-user mode
RUN curl -L https://nixos.org/nix/install -o /tmp/install-nix.sh && \
    chmod +x /tmp/install-nix.sh && \
    sh /tmp/install-nix.sh --no-daemon && \
    rm /tmp/install-nix.sh

# Setup environment for interactive and non-interactive shells
RUN echo '. /root/.nix-profile/etc/profile.d/nix.sh' >> /root/.bashrc && \
    echo '. /root/.nix-profile/etc/profile.d/nix.sh' >> /root/.profile

# Set PATH for Docker RUN commands and container runtime
ENV PATH="/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}"
ENV NIX_PATH="/root/.nix-defexpr/channels"

# Update nix channels
RUN . /root/.nix-profile/etc/profile.d/nix.sh && nix-channel --update

# Enable experimental features (flakes, nix-command)
RUN mkdir -p /root/.config/nix && \
    echo 'extra-experimental-features = nix-command flakes' > /root/.config/nix/nix.conf

# Verify installation
RUN nix-shell -p nix-info --run "nix-info -m"

SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash"]
