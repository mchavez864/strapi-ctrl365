# Dockerfile simple para entorno de desarrollo de Strapi v5

FROM node:22-alpine

# Dependencias necesarias para Strapi (sharp/vips, etc.)
RUN apk add --no-cache \
    build-base \
    gcc \
    g++ \
    python3 \
    git \
    vips-dev

# Directorio de trabajo
WORKDIR /opt/app

# Copiamos solo package.json primero para aprovechar caché
COPY package.json ./

# Instalamos dependencias SIEMPRE con npm (evitamos problemas con yarn)
RUN npm install --prefer-offline --no-audit

# Copiamos el resto del código
COPY . .

# Variable de entorno por defecto para desarrollo
ENV NODE_ENV=development

# Build del admin de Strapi
RUN npm run build

# Puerto por defecto de Strapi
EXPOSE 1337

# Comando por defecto: modo desarrollo
CMD ["npm", "run", "develop"]
