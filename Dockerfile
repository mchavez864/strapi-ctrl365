# ---- BUILD STAGE ----
FROM node:18-slim AS builder

# Dependencias necesarias para Strapi, sharp, vips, sqlite, etc.
RUN apt-get update && apt-get install -y \
  build-essential \
  python3 \
  pkg-config \
  libvips-dev \
  git \
  && apt-get clean

WORKDIR /app

# Copiamos package.json y lockfiles
COPY package*.json yarn.lock* pnpm-lock.yaml* .npmrc* ./

# Instalamos dependencias según el lockfile disponible
RUN \
  if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm install --frozen-lockfile; \
  else npm install; \
  fi

# Copiamos todo el código
COPY . .

# Definimos los ARG de Azure y MySQL para build (se pasan desde workflow)
ARG AZURE_ACCOUNT_NAME
ARG AZURE_ACCOUNT_KEY
ARG AZURE_CONTAINER_NAME
ARG AZURE_DEFAULT_PATH
ARG AZURE_REMOVE_CN

ARG DATABASE_CLIENT
ARG DATABASE_HOST
ARG DATABASE_PORT
ARG DATABASE_NAME
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD
ARG DATABASE_SSL

# Los convertimos en ENV temporales para que Strapi build no falle
ENV AZURE_ACCOUNT_NAME=$AZURE_ACCOUNT_NAME
ENV AZURE_ACCOUNT_KEY=$AZURE_ACCOUNT_KEY
ENV AZURE_CONTAINER_NAME=$AZURE_CONTAINER_NAME
ENV AZURE_DEFAULT_PATH=$AZURE_DEFAULT_PATH
ENV AZURE_REMOVE_CN=$AZURE_REMOVE_CN

ENV DATABASE_CLIENT=$DATABASE_CLIENT
ENV DATABASE_HOST=$DATABASE_HOST
ENV DATABASE_PORT=$DATABASE_PORT
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USERNAME=$DATABASE_USERNAME
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD
ENV DATABASE_SSL=$DATABASE_SSL

# Build del admin
RUN yarn build

# ---- RUNTIME STAGE ----
FROM node:18-slim

# Dependencias runtime
RUN apt-get update && apt-get install -y \
  libvips-dev \
  && apt-get clean

WORKDIR /app

ENV NODE_ENV=production
EXPOSE 1337

# Copiamos todo desde build stage
COPY --from=builder /app /app

# Variables reales se sobrescriben en ACA con --set-env-vars
ENV AZURE_ACCOUNT_NAME=$AZURE_ACCOUNT_NAME
ENV AZURE_ACCOUNT_KEY=$AZURE_ACCOUNT_KEY
ENV AZURE_CONTAINER_NAME=$AZURE_CONTAINER_NAME
ENV AZURE_DEFAULT_PATH=$AZURE_DEFAULT_PATH
ENV AZURE_REMOVE_CN=$AZURE_REMOVE_CN

ENV DATABASE_CLIENT=$DATABASE_CLIENT
ENV DATABASE_HOST=$DATABASE_HOST
ENV DATABASE_PORT=$DATABASE_PORT
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USERNAME=$DATABASE_USERNAME
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD
ENV DATABASE_SSL=$DATABASE_SSL

# Usuario no root
RUN useradd -m strapi
USER strapi

CMD ["npm", "run", "start"]
