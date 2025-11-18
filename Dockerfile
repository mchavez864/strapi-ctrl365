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

# Copiamos package.json y lockfile si existe
COPY package*.json ./

# Instalamos dependencias según lockfile disponible (usa npm)
RUN if [ -f package-lock.json ]; then npm ci --prefer-offline --no-audit --progress=false; else npm install --no-audit --progress=false; fi

# Copiamos el resto del código
COPY . .

# ---- ARGs de secretos y DB (se pasan desde workflow) ----
# Azure Storage
ARG AZURE_ACCOUNT_NAME
ARG AZURE_ACCOUNT_KEY
ARG AZURE_CONTAINER_NAME
ARG AZURE_DEFAULT_PATH
ARG AZURE_REMOVE_CN

# MySQL
ARG DATABASE_CLIENT
ARG DATABASE_HOST
ARG DATABASE_PORT
ARG DATABASE_NAME
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD
ARG DATABASE_SSL

# Secrets de Strapi
ARG ADMIN_JWT_SECRET
ARG APP_KEYS
ARG API_TOKEN_SALT
ARG JWT_SECRET

# ---- ENV temporales para build (no hardcodea valores, vienen por ARG) ----
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

ENV ADMIN_JWT_SECRET=$ADMIN_JWT_SECRET
ENV APP_KEYS=$APP_KEYS
ENV API_TOKEN_SALT=$API_TOKEN_SALT
ENV JWT_SECRET=$JWT_SECRET

# Build del admin
RUN npm run build

# ---- RUNTIME STAGE ----
FROM node:18-slim

# Dependencias runtime para sharp/vips si hace falta
RUN apt-get update && apt-get install -y \
  libvips-dev \
  && apt-get clean

WORKDIR /app
ENV NODE_ENV=development
EXPOSE 1337

# Copiamos desde build
COPY --from=builder /app /app

# Declaramos ENV runtime (serán sobrescritos por ACA con --set-env-vars)
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

ENV ADMIN_JWT_SECRET=$ADMIN_JWT_SECRET
ENV APP_KEYS=$APP_KEYS
ENV API_TOKEN_SALT=$API_TOKEN_SALT
ENV JWT_SECRET=$JWT_SECRET

# Usuario no root
RUN useradd -m strapi
USER strapi

CMD ["npm", "run", "start"]
