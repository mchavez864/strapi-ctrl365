###########################
# 1) BUILDER STAGE
###########################
FROM node:22-alpine AS builder

# Dependencias necesarias para Strapi (sharp, sqlite, builds)
RUN apk add --no-cache \
    build-base \
    gcc \
    g++ \
    python3 \
    git \
    vips-dev

WORKDIR /opt/app

# Copiamos manifest primero:
COPY package.json package-lock.json* yarn.lock* ./

# Instalamos dependencias usando npm SIEMPRE
RUN npm install --prefer-offline --no-audit

# Copiamos el resto del proyecto
COPY . .

# VARIABLES PARA BUILD (vienen desde GitHub Actions)
ARG APP_KEYS
ARG API_TOKEN_SALT
ARG ADMIN_JWT_SECRET
ARG TRANSFER_TOKEN_SALT
ARG JWT_SECRET
ARG ENCRYPTION_KEY

ARG DATABASE_CLIENT
ARG DATABASE_HOST
ARG DATABASE_PORT
ARG DATABASE_NAME
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD
ARG DATABASE_SSL

ARG AZURE_ACCOUNT_NAME
ARG AZURE_ACCOUNT_KEY
ARG AZURE_CONTAINER_NAME
ARG AZURE_DEFAULT_PATH
ARG AZURE_DEFAULT_CACHE_CONTROL
ARG AZURE_REMOVE_CN

# Exportamos como ENV para que Strapi build pueda acceder
ENV APP_KEYS=${APP_KEYS}
ENV API_TOKEN_SALT=${API_TOKEN_SALT}
ENV ADMIN_JWT_SECRET=${ADMIN_JWT_SECRET}
ENV TRANSFER_TOKEN_SALT=${TRANSFER_TOKEN_SALT}
ENV JWT_SECRET=${JWT_SECRET}
ENV ENCRYPTION_KEY=${ENCRYPTION_KEY}

ENV DATABASE_CLIENT=${DATABASE_CLIENT}
ENV DATABASE_HOST=${DATABASE_HOST}
ENV DATABASE_PORT=${DATABASE_PORT}
ENV DATABASE_NAME=${DATABASE_NAME}
ENV DATABASE_USERNAME=${DATABASE_USERNAME}
ENV DATABASE_PASSWORD=${DATABASE_PASSWORD}
ENV DATABASE_SSL=${DATABASE_SSL}

ENV AZURE_ACCOUNT_NAME=${AZURE_ACCOUNT_NAME}
ENV AZURE_ACCOUNT_KEY=${AZURE_ACCOUNT_KEY}
ENV AZURE_CONTAINER_NAME=${AZURE_CONTAINER_NAME}
ENV AZURE_DEFAULT_PATH=${AZURE_DEFAULT_PATH}
ENV AZURE_DEFAULT_CACHE_CONTROL=${AZURE_DEFAULT_CACHE_CONTROL}
ENV AZURE_REMOVE_CN=${AZURE_REMOVE_CN}

# Build de Strapi (admin panel + server)
RUN npm run build


###########################
# 2) RUNTIME STAGE
###########################
FROM node:22-alpine

RUN apk add --no-cache vips-dev

WORKDIR /opt/app

# Copiamos node_modules y la app construida
COPY --from=builder /opt/app/node_modules ./node_modules
COPY --from=builder /opt/app ./

# Strapi PORT
EXPOSE 1337

ENV NODE_ENV=development

# Inicio del servidor Strapi
CMD ["npm", "run", "start"]
