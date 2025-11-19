# ---- BUILD STAGE ----
FROM node:18-slim AS builder

# Dependencias necesarias para Strapi y build de assets
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    pkg-config \
    libvips-dev \
    git \
    && apt-get clean

WORKDIR /app

# Copiamos package.json y yarn.lock
COPY package.json yarn.lock ./

# Instalamos dependencias con network-concurrency 1
RUN yarn install --frozen-lockfile --network-concurrency 1

# Copiamos el código fuente
COPY . .

# Build del admin
RUN yarn build

# ---- RUNTIME STAGE ----
FROM node:18-slim

# Dependencias necesarias para runtime
RUN apt-get update && apt-get install -y libvips-dev && apt-get clean

WORKDIR /app
EXPOSE 1337
ENV NODE_ENV=production

# Copiamos la app desde build
COPY --from=builder /app /app

# No definimos ENV con secretos directamente en el Dockerfile.
# GitHub Actions pasará secrets en runtime mediante `--set-env-vars`.
CMD ["yarn", "start"]
