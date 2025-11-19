# ============================
#       BUILDER STAGE
# ============================
FROM node:18-slim AS builder

# Dependencias necesarias para Strapi + sharp + vips
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    pkg-config \
    libvips-dev \
    git \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiamos solo dependencias primero
COPY package*.json ./

# Instalamos dependencias (sin ci, para evitar fallos)
RUN npm install --production --no-audit --prefer-offline

# Copiamos el resto del proyecto
COPY . .

# Build del admin panel
RUN npm run build


# ============================
#       RUNTIME STAGE
# ============================
FROM node:18-slim AS runtime

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libvips-dev \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production

COPY --from=builder /app /app

EXPOSE 1337

CMD ["npm", "start"]
