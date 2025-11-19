# Dockerfile para Strapi v5 - Development

# Base image
FROM node:22-alpine

# Dependencias necesarias para compilación y Strapi dev
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git

# Directorio de trabajo
WORKDIR /opt/app

# Copiar archivos de dependencias
COPY package.json package-lock.json yarn.lock* ./

# Instalar todas las dependencias (prod + dev)
RUN npm install --prefer-offline --no-audit

# Copiar todo el código
COPY . .

# Variables de entorno necesarias
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}
ENV DATABASE_CLIENT=mysql
ENV DATABASE_HOST=${DATABASE_HOST}
ENV DATABASE_PORT=3306
ENV DATABASE_NAME=${DATABASE_NAME}
ENV DATABASE_USERNAME=${DATABASE_USERNAME}
ENV DATABASE_PASSWORD=${DATABASE_PASSWORD}
ENV DATABASE_SSL=true

ENV ADMIN_STRAPI_JWT_SECRET=${ADMIN_STRAPI_JWT_SECRET}
ENV STRAPI_APP_KEYS=${STRAPI_APP_KEYS}
ENV STRAPI_API_TOKEN_SALT=${STRAPI_API_TOKEN_SALT}
ENV STRAPI_JWT_SECRET=${STRAPI_JWT_SECRET}

ENV AZURE_ACCOUNT_NAME=${AZURE_ACCOUNT_NAME}
ENV AZURE_ACCOUNT_KEY=${AZURE_ACCOUNT_KEY}
ENV AZURE_CONTAINER_NAME=${AZURE_CONTAINER_NAME}
ENV AZURE_DEFAULT_PATH=${AZURE_DEFAULT_PATH}
ENV AZURE_REMOVE_CN=${AZURE_REMOVE_CN}

# Exponer puerto Strapi
EXPOSE 1337

# Ejecutar Strapi en modo desarrollo
CMD ["npm", "run", "develop"]
