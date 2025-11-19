###########################
# 1) BUILDER STAGE
###########################
FROM node:22-alpine AS builder

# Dependencias necesarias para Strapi (sharp / vips / builds)
RUN apk add --no-cache \
  build-base \
  gcc \
  g++ \
  python3 \
  git \
  vips-dev

WORKDIR /opt/app

# ==== ARGs que vienen desde GitHub Actions ====
ARG NODE_ENV=development

ARG DATABASE_CLIENT=mysql
ARG DATABASE_HOST
ARG DATABASE_PORT=3306
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

# ==== Exportamos como ENV para que Strapi build los vea ====
ENV NODE_ENV=${NODE_ENV}

ENV DATABASE_CLIENT=${DATABASE_CLIENT}
ENV DATABASE_HOST=${DATABASE_HOST}
ENV DATABASE_PORT=${DATABASE_PORT}
ENV DATABASE_NAME=${DATABASE_NAME}
ENV DATABASE_USERNAME=${DATABASE_USERNAME}
ENV DATABASE_PASSWORD=${DATABASE_PASSWORD}

# Mapeo de nombres prefijados STRAPI_ -> variables que usa Strapi
ENV APP_KEYS=${STRAPI_APP_KEYS}
ENV API_TOKEN_SALT=${STRAPI_API_TOKEN_SALT}
ENV ADMIN_JWT_SECRET=${ADMIN_STRAPI_JWT_SECRET}
ENV JWT_SECRET=${STRAPI_JWT_SECRET}

ENV AZURE_ACCOUNT_NAME=${AZURE_ACCOUNT_NAME}
ENV AZURE_ACCOUNT_KEY=${AZURE_ACCOUNT_KEY}
ENV AZURE_CONTAINER_NAME=${AZURE_CONTAINER_NAME}
ENV AZURE_DEFAULT_PATH=${AZURE_DEFAULT_PATH}
ENV AZURE_REMOVE_CN=${AZURE_REMOVE_CN}

# Copiamos package.json (y locks si existen) para aprovechar cache
COPY package.json package-lock.json* yarn.lock* ./

# Instalamos dependencias SIEMPRE con npm (evitamos problemas con yarn)
RUN npm install --prefer-offline --no-audit

# Copiamos el resto del código de la app
COPY . .

# Build del admin de Strapi
RUN npm run build


###########################
# 2) RUNTIME STAGE
###########################
FROM node:22-alpine

# Dependencias en runtime para sharp / vips
RUN apk add --no-cache vips-dev

WORKDIR /opt/app

# Copiamos node_modules y la app construida desde el builder
COPY --from=builder /opt/app/node_modules ./node_modules
COPY --from=builder /opt/app ./

# Puerto de Strapi
EXPOSE 1337

# En el contenedor de Azure, las variables reales se sobreescriben
# con --set-env-vars desde el workflow
ENV NODE_ENV=development

# Comando por defecto: servidor Strapi (no modo "develop" interactivo)
CMD ["npm", "run", "start"]
