FROM ruby:3.0.0

# dev user setup
ARG INSTALL_ZSH="false"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
ARG UPGRADE_PACKAGES="true"
ARG INSTALL_OH_MYS="false"
COPY library-scripts/common-debian.sh /tmp/library-scripts/
RUN apt-get update \
    # The script is from https://github.com/microsoft/vscode-dev-containers/blob/v0.155.0/script-library/common-debian.sh
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "${INSTALL_OH_MYS}" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/
