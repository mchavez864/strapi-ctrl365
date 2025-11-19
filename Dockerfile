###########################
# 1) BUILDER STAGE
###########################
FROM node:22-alpine AS builder

RUN apk add --no-cache \
  build-base \
  gcc \
  g++ \
  python3 \
  git \
  vips-dev

WORKDIR /opt/app

ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

COPY package.json package-lock.json* yarn.lock* ./
RUN npm install --prefer-offline --no-audit

COPY . .

# COMPILA EL ADMIN AQUÍ ✔
RUN npm run build

###########################
# 2) RUNTIME STAGE
###########################
FROM node:22-alpine

RUN apk add --no-cache vips-dev

WORKDIR /opt/app

COPY --from=builder /opt/app/node_modules ./node_modules
COPY --from=builder /opt/app ./

EXPOSE 1337

# SEGUIR EN ENTORNO DEVELOPMENT (para Content Type Builder)
ENV NODE_ENV=development

# EJECUTAR MODO PRODUCCIÓN (sirve admin buildiado)
CMD ["npm", "run", "start"]
