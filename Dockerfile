ARG BASH_VERSION=5.2.15

FROM scratch AS bash_unit
ADD https://github.com/bash-unit/bash_unit.git#v2.3.3 /tmp/bash_unit

FROM "bash:$BASH_VERSION-alpine3.18"

RUN  apk add --no-cache diffutils 
COPY --from=bash_unit /tmp/bash_unit/bash_unit /usr/local/bin/bash_unit


# Add a non-root user with name "$USER"
# and set its default shell to bash
ARG USER=testuser
RUN apk add shadow
RUN useradd -m -s /bin/bash "$USER"

# Change the user's password to 'password'
RUN "$USER:password" | chpasswd

# Use the user $USER as the default user
# for the container image
USER "$USER" 

WORKDIR /var/task
