FROM node:lts-alpine3.18 AS base
WORKDIR /usr/src/wpp-server
RUN apk update && \
    apk add --no-cache \
    vips-dev \
    fftw-dev \
    gcc \
    g++ \
    make \
    git \
    libc6-compat \
    && rm -rf /var/cache/apk/*

FROM base AS build
WORKDIR /usr/src/wpp-server
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npm run build

FROM base
WORKDIR /usr/src/wpp-server/
RUN apk add --no-cache chromium
COPY . .
COPY --from=build /usr/src/wpp-server/ /usr/src/wpp-server/
EXPOSE 21465
ENTRYPOINT ["node", "dist/server.js"]
