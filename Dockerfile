# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20230227-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.14.4-erlang-25.3.1-debian-bullseye-20230227-slim

# RUNTIME
ARG ELIXIR_VERSION=1.14.4
ARG OTP_VERSION=25.3.1
ARG DEBIAN_VERSION=bullseye-20230227-slim
ARG NODE_VERSION=20.5.0
ARG NODE_MAX_OLD_SPACE_SIZE=1024

#1.15.4-erlang-26.0.2-debian-bullseye-20230612-slim
#1.15.4-erlang-25.3.2.5-debian-bullseye-20230612-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder
ARG NODE_VERSION

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential curl git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# install nodejs
COPY bin/install_node bin/install_node
RUN bin/install_node ${NODE_VERSION}

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./

ENV MIX_ENV="prod"

RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/

RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets
RUN node --version
RUN npm install --prefix assets

ARG SECRET_KEY_BASE

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# DB setup
ARG DATABASE_URL
# RUN mix ash_postgres.create
# RUN mix ash_postgres.migrate

COPY rel rel
RUN mix release

######################################################################

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}
ARG NODE_VERSION
ARG NODE_MAX_OLD_SPACE_SIZE
ENV NODE_OPTIONS=--max-old-space-size=${NODE_MAX_OLD_SPACE_SIZE}

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 curl pgpgpg locales tini && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

# install nodejs
COPY bin/install_node bin/install_node
RUN bin/install_node ${NODE_VERSION}

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

ENV MIX_ENV="prod"
ARG APP_NAME="poffee"

# copy the entrypoint script which will run bin/migrate first
COPY --chown=nobody:nobody bin/entrypoint.sh /

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:nobody /app/_build/${MIX_ENV}/rel/${APP_NAME} ./

USER nobody

ENTRYPOINT ["tini", "--", "/bin/sh", "/entrypoint.sh"]
CMD ["bin/poffee", "start"]