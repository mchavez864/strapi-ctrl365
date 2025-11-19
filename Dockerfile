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

# Podemos pasar solo NODE_ENV como build-arg si lo necesitás
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

# Copiamos manifest primero para aprovechar cache
COPY package.json package-lock.json* yarn.lock* ./

# Instalamos dependencias con npm (evitamos problemas con yarn)
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

# En el container se sobreescriben con --set-env-vars
ENV NODE_ENV=development

# Comando por defecto: servidor Strapi
CMD ["npm", "run", "start"]
