# Base image
FROM node:22-alpine

# Dependencias necesarias para compilación y Strapi dev
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git

# Set working directory
WORKDIR /opt/app

# Copiar package.json + lockfiles
COPY package.json package-lock.json yarn.lock* ./

# Instalar todas las dependencias (prod + dev)
RUN npm install --prefer-offline --no-audit

# Copiar código
COPY . .

# Exponer puerto de Strapi dev
EXPOSE 1337

# Ejecutar Strapi en modo desarrollo
CMD ["npm", "run", "develop"]

