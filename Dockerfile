FROM alpine:3.21

# Install prerequisites (from tutorial section 1.2)
RUN apk add --no-cache \
    bash \
    curl \
    shadow \
    sudo \
    xz \
    ca-certificates

# Create nix directory and install Nix (single-user mode for Docker)
RUN addgroup -S nixbld && \
    for i in $(seq 1 10); do adduser -S -G nixbld nixbld$i; done

# Install Nix in single-user mode (simpler for Docker)
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Setup environment for interactive and non-interactive shells
RUN echo '. /root/.nix-profile/etc/profile.d/nix.sh' >> /root/.bashrc && \
    echo '. /root/.nix-profile/etc/profile.d/nix.sh' >> /root/.profile

# Set PATH for Docker RUN commands and container runtime
ENV PATH="/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}"
ENV NIX_PATH="/root/.nix-defexpr/channels"

# Update nix channels
RUN . /root/.nix-profile/etc/profile.d/nix.sh && nix-channel --update

# Enable experimental features (flakes, nix-command) - section 1.7
RUN mkdir -p /root/.config/nix && \
    echo 'extra-experimental-features = nix-command flakes' > /root/.config/nix/nix.conf

# Verify installation
RUN nix-shell -p nix-info --run "nix-info -m"

SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash"]
