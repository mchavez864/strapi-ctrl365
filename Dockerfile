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

# Set working directory
WORKDIR /app

# -------- Copiamos solamente archivos de dependencias --------
COPY package*.json ./

# -------- Instalación de dependencias --------
# Flags recomendados para CI/CD:
# --omit=dev             → omite dev deps (Strapi v5 no las necesita para build)
# --no-audit             → evita errores de auditoría en CI
# --prefer-offline       → reduce fallos en GitHub Actions
RUN npm ci --omit=dev --no-audit --prefer-offline

# -------- Copiamos el resto del código --------
COPY . .

# -------- Build del panel de administración de Strapi --------
RUN npm run build


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

ENV NODE_ENV=staging

# Copiamos del builder solo lo necesario
COPY --from=builder /app /app

EXPOSE 1337

CMD ["npm", "start"]
