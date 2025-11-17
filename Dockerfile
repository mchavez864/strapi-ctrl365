Dockerfile
 
# ---- BUILD STAGE ----

FROM node:18-slim as build
 
# Necesario para compilar sharp, vips, sqlite, etc.

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
 
# Instalamos dependencias

RUN \

  if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \

  elif [ -f package-lock.json ]; then npm ci; \

  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm install --frozen-lockfile; \

  else npm install; \

  fi
 
COPY . .
 
# Build de Strapi

RUN \

  if [ -f yarn.lock ]; then yarn build; \

  elif [ -f package-lock.json ]; then npm run build; \

  else npm run build; \

  fi
 
# ---- RUNTIME STAGE ----

FROM node:18-slim
 
RUN apt-get update && apt-get install -y \

  libvips-dev \
&& apt-get clean
 
ENV NODE_ENV=production

WORKDIR /app
 
COPY --from=build /app /app
 
# Usuario no root

RUN useradd -m strapi

USER strapi
 
EXPOSE 1337
 
CMD ["npm", "run", "start"]

 
