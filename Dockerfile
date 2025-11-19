# ============================
#       BUILDER STAGE
# ============================
FROM node:22-alpine AS builder

# Dependencias para Strapi + sharp
RUN apk add --no-cache \
    build-base \
    python3 \
    vips-dev \
    libpng-dev \
    zlib-dev \
    git \
    bash \
    ca-certificates

WORKDIR /opt/app

# Copiamos package.json y lockfile si existe
COPY package.json package-lock.json* ./

# Instalamos dependencias sin CI
RUN npm install --production --no-audit --prefer-offline

# Copiamos todo el código
COPY . .

# Build del admin panel
RUN npm run build

# ============================
#       RUNTIME STAGE
# ============================
FROM node:22-alpine AS runtime

# Dependencias necesarias en runtime
RUN apk add --no-cache \
    vips-dev \
    libpng-dev \
    zlib-dev \
    ca-certificates \
    bash

WORKDIR /opt/app
ENV NODE_ENV=production

# Copiamos node_modules y build desde builder
COPY --from=builder /opt/app/node_modules ./node_modules
COPY --from=builder /opt/app ./ 

ENV PATH=/opt/app/node_modules/.bin:$PATH

# Corre como usuario no root
RUN addgroup -S app && adduser -S app -G app
RUN chown -R app:app /opt/app
USER app

EXPOSE 1337
CMD ["npm", "start"]
