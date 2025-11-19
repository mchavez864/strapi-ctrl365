# ---- BUILD STAGE ----
FROM node:18-slim AS builder

# Instalar dependencias necesarias para Strapi y build de assets
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    pkg-config \
    libvips-dev \
    git \
    && apt-get clean

WORKDIR /app

# Copiamos package.json, yarn.lock y .npmrc si existe
COPY package.json yarn.lock* .npmrc* ./

# Instalamos dependencias con yarn, usando network-concurrency 1 para CI/CD
RUN yarn install --frozen-lockfile --network-concurrency 1

# Copiamos el resto del código fuente
COPY . .

# Definimos argumentos de build (serán pasados desde el workflow)
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
ARG ADMIN_JWT_SECRET
ARG APP_KEYS
ARG API_TOKEN_SALT
ARG JWT_SECRET

# Build del panel de administración
RUN yarn build

# ---- RUNTIME STAGE ----
FROM node:18-slim

# Instalar librerías necesarias para runtime
RUN apt-get update && apt-get install -y \
    libvips-dev \
    && apt-get clean

WORKDIR /app

# Entorno de Node
ENV NODE_ENV=production
EXPOSE 1337

# Copiamos desde build stage
COPY --from=builder /app /app

# Declaramos variables de entorno en tiempo de ejecución (pueden ser sobrescritas por GitHub Actions)
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

# Comando por defecto para iniciar Strapi
CMD ["yarn", "start"]
