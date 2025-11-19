# ============================
#       BUILDER STAGE
# ============================
FROM node:18-slim AS builder

# -------- Dependencias del sistema necesarias --------
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    pkg-config \
    libvips-dev \
    git \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Define la carpeta de trabajo
WORKDIR /app

# -------- Copia de archivos de dependencias --------
COPY package.json yarn.lock ./

# -------- Instalación de dependencias --------
# network-concurrency y prefer-offline ayudan a evitar caídas en CI
RUN yarn install --frozen-lockfile --network-concurrency 1 --prefer-offline

# -------- Copia del código fuente --------
COPY . .

# -------- Build del panel de administración --------
RUN yarn build


# ============================
#       RUNTIME STAGE
# ============================
FROM node:18-slim AS runtime

WORKDIR /app

# -------- Dependencias necesarias en runtime --------
RUN apt-get update && apt-get install -y \
    libvips-dev \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production

# Copiamos solo lo necesario para producir una imagen limpia
COPY --from=builder /app /app

# Exponer el puerto de Strapi
EXPOSE 1337

# Iniciar Strapi
CMD ["yarn", "start"]
