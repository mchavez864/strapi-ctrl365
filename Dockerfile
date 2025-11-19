# ---------------------- Stage 1: Builder ----------------------
FROM node:22-alpine AS builder

# Dependencias para compilar addons y Strapi
RUN apk add --no-cache build-base gcc g++ python3 git vips-dev

# Definimos el entorno
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

# Directorio de trabajo
WORKDIR /opt/app

# Copiamos solo package.json y yarn.lock (si existe)
COPY package.json yarn.lock* ./

# Instalamos dependencias (Yarn si hay lockfile, sino npm)
RUN if [ -f yarn.lock ]; then \
      yarn install --prefer-offline --no-audit; \
    else \
      npm install --prefer-offline --no-audit; \
    fi

# Copiamos el resto del código
COPY . .

# Build de Strapi (para development generalmente no es necesario, pero se deja)
RUN if [ -f yarn.lock ]; then \
      yarn build; \
    else \
      npm run build; \
    fi

# ---------------------- Stage 2: Runtime ----------------------
FROM node:22-alpine

# Dependencias necesarias para Strapi runtime
RUN apk add --no-cache vips-dev

# Variables de entorno sensibles pasadas como build-args
ARG DATABASE_CLIENT
ARG DATABASE_HOST
ARG DATABASE_PORT
ARG DATABASE_NAME
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD
ARG ADMIN_STRAPI_JWT_SECRET
ARG STRAPI_APP_KEYS
ARG STRAPI_API_TOKEN_SALT
ARG STRAPI_JWT_SECRET
ARG AZURE_ACCOUNT_NAME
ARG AZURE_ACCOUNT_KEY
ARG AZURE_CONTAINER_NAME
ARG AZURE_DEFAULT_PATH
ARG AZURE_REMOVE_CN

ENV DATABASE_CLIENT=${DATABASE_CLIENT}
ENV DATABASE_HOST=${DATABASE_HOST}
ENV DATABASE_PORT=${DATABASE_PORT}
ENV DATABASE_NAME=${DATABASE_NAME}
ENV DATABASE_USERNAME=${DATABASE_USERNAME}
ENV DATABASE_PASSWORD=${DATABASE_PASSWORD}
ENV ADMIN_STRAPI_JWT_SECRET=${ADMIN_STRAPI_JWT_SECRET}
ENV STRAPI_APP_KEYS=${STRAPI_APP_KEYS}
ENV STRAPI_API_TOKEN_SALT=${STRAPI_API_TOKEN_SALT}
ENV STRAPI_JWT_SECRET=${STRAPI_JWT_SECRET}
ENV AZURE_ACCOUNT_NAME=${AZURE_ACCOUNT_NAME}
ENV AZURE_ACCOUNT_KEY=${AZURE_ACCOUNT_KEY}
ENV AZURE_CONTAINER_NAME=${AZURE_CONTAINER_NAME}
ENV AZURE_DEFAULT_PATH=${AZURE_DEFAULT_PATH}
ENV AZURE_REMOVE_CN=${AZURE_REMOVE_CN}
ENV NODE_ENV=development

# Directorio de trabajo
WORKDIR /opt/app

# Copiamos node_modules desde builder
COPY --from=builder /opt/app/node_modules ./node_modules
COPY --from=builder /opt/app ./

# Permisos
RUN chown -R node:node /opt/app
USER node

# Puerto por defecto de Strapi
EXPOSE 1337

# CMD para desarrollo
CMD ["yarn", "develop"]
