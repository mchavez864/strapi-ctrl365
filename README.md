# CTRL 365 CMS

Sistema de gestión de contenidos (CMS) construido con Strapi para el proyecto CTRL 365.

## Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Tecnologías](#tecnologías)
- [Requisitos del Sistema](#requisitos-del-sistema)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Comandos Disponibles](#comandos-disponibles)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Base de Datos](#base-de-datos)
- [API](#api)
- [Autenticación y Permisos](#autenticación-y-permisos)
- [Despliegue](#despliegue)
- [Recursos](#recursos)

## Descripción General

**CTRL 365 CMS** es una aplicación headless CMS basada en Strapi v5.28.0. Strapi es un CMS de código abierto que proporciona una API flexible y personalizable para gestionar contenido de forma eficiente.

### ¿Qué es Strapi?

Strapi es un Headless CMS de código abierto que te permite:

- Crear APIs REST y GraphQL automáticamente
- Gestionar contenido a través de un panel de administración intuitivo
- Personalizar completamente tu modelo de datos
- Controlar permisos y autenticación de usuarios
- Extender funcionalidades mediante plugins

## Tecnologías

Este proyecto utiliza las siguientes tecnologías:

- **Strapi**: v5.28.0 - Framework CMS headless
- **Node.js**: v18.0.0 - v22.x.x
- **MySQL**: v3.9.8 (Cliente)
- **React**: ^18.0.0 - Para el panel de administración
- **React Router**: ^6.0.0 - Navegación en el admin panel
- **Styled Components**: ^6.0.0 - Estilos del panel

### Plugins Incluidos

- `@strapi/plugin-users-permissions` - Gestión de usuarios y permisos
- `@strapi/plugin-cloud` - Integración con Strapi Cloud

## Requisitos del Sistema

Antes de comenzar, asegúrate de tener instalado:

- **Node.js**: Versión 18.0.0 o superior (hasta v22.x.x)
- **npm**: Versión 6.0.0 o superior
- **Base de datos**: MySQL, PostgreSQL o SQLite (SQLite por defecto)

## Instalación

### 1. Clonar el repositorio

```bash
git clone [URL_DEL_REPOSITORIO]
cd ctrl-365-cms
```

### 2. Instalar dependencias

```bash
npm install
```

### 3. Configurar variables de entorno

Copia el archivo `.env.example` a `.env` y configura las variables según tu entorno:

```bash
cp .env.example .env
```

Edita el archivo `.env` con tus valores:

```env
HOST=0.0.0.0
PORT=1337
APP_KEYS="[TU_APP_KEY_1],[TU_APP_KEY_2]"
API_TOKEN_SALT=[TU_API_TOKEN_SALT]
ADMIN_JWT_SECRET=[TU_ADMIN_JWT_SECRET]
TRANSFER_TOKEN_SALT=[TU_TRANSFER_TOKEN_SALT]
JWT_SECRET=[TU_JWT_SECRET]
ENCRYPTION_KEY=[TU_ENCRYPTION_KEY]

# Configuración de base de datos
# DATABASE_CLIENT=mysql
# DATABASE_HOST=localhost
# DATABASE_PORT=3306
# DATABASE_NAME=ctrl365
# DATABASE_USERNAME=root
# DATABASE_PASSWORD=password
```

**Importante**: Genera valores seguros para los secretos. Puedes usar herramientas como:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

## Configuración

### Base de Datos

El proyecto utiliza MySQL como motor de base de datos:


#### MySQL

```env
DATABASE_CLIENT=mysql
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_NAME=ctrl365
DATABASE_USERNAME=root
DATABASE_PASSWORD=password
DATABASE_SSL=false
```

### Configuración del Servidor

El servidor se configura en [config/server.js](config/server.js). Por defecto escucha en:

- **Host**: `0.0.0.0`
- **Puerto**: `1337`

Accede al panel de administración en: `http://localhost:1337/admin`

## Comandos Disponibles

### Desarrollo

Inicia la aplicación en modo desarrollo con recarga automática:

```bash
npm run develop
# o
npm run dev
```

El servidor se iniciará en `http://localhost:1337` y el panel de administración en `http://localhost:1337/admin`.

### Producción

Construye el panel de administración para producción:

```bash
npm run build
```

Inicia el servidor en modo producción (sin recarga automática):

```bash
npm run start
```

### Otros Comandos

```bash
# Acceder a la consola de Strapi
npm run console

# Desplegar en Strapi Cloud
npm run deploy

# Actualizar Strapi a la última versión
npm run upgrade

# Ver qué se actualizaría (sin realizar cambios)
npm run upgrade:dry
```

## Estructura del Proyecto

```
ctrl-365-cms/
├── config/              # Configuración de la aplicación
│   ├── admin.js        # Configuración del panel de administración
│   ├── api.js          # Configuración de la API
│   ├── database.js     # Configuración de la base de datos
│   ├── middlewares.js  # Configuración de middlewares
│   ├── plugins.js      # Configuración de plugins
│   └── server.js       # Configuración del servidor
├── database/           # Archivos de base de datos (SQLite)
├── public/             # Archivos públicos estáticos
├── src/
│   ├── admin/         # Personalización del panel de administración
│   ├── api/           # Definición de APIs y content-types
│   ├── extensions/    # Extensiones de plugins
│   └── index.js       # Punto de entrada de la aplicación
├── .env               # Variables de entorno (no versionado)
├── .env.example       # Ejemplo de variables de entorno
└── package.json       # Dependencias y scripts
```

## Base de Datos

### Migraciones

Strapi gestiona automáticamente las migraciones de base de datos. Cuando creas o modificas Content Types en el panel de administración, Strapi actualiza el esquema automáticamente.

### Backup

Para MySQL, utiliza las herramientas nativas de backup (`mysqldump`, `pg_dump`).

## API

### Endpoints Automáticos

Strapi genera automáticamente endpoints REST para cada Content Type que crees:

- `GET /api/[content-type]` - Listar todos
- `GET /api/[content-type]/:id` - Obtener por ID
- `POST /api/[content-type]` - Crear
- `PUT /api/[content-type]/:id` - Actualizar
- `DELETE /api/[content-type]/:id` - Eliminar

### Ejemplo de Uso

```javascript
// Obtener todas las entradas
fetch('http://localhost:1337/api/[content-type]')
  .then(response => response.json())
  .then(data => console.log(data));
```

### GraphQL (Opcional)

Para habilitar GraphQL, instala el plugin:

```bash
npm run strapi install graphql
```

## Autenticación y Permisos

### Usuarios y Roles

El plugin `users-permissions` incluido proporciona:

- Sistema de autenticación JWT
- Registro y login de usuarios
- Roles predefinidos: Public, Authenticated
- Permisos granulares por endpoint

### Configurar Permisos

1. Accede al panel de administración
2. Ve a **Settings** → **Roles** → **Public/Authenticated**
3. Configura los permisos para cada Content Type

### API Tokens

Para acceder a la API sin autenticación de usuario, crea API Tokens en:

**Settings** → **API Tokens** → **Create new API Token**

Usa el token en tus peticiones:

```javascript
fetch('http://localhost:1337/api/[content-type]', {
  headers: {
    'Authorization': 'Bearer [TU_TOKEN]'
  }
})
```

## Despliegue

### Strapi Cloud

```bash
npm run deploy
```

### Despliegue Manual

#### Preparación

```bash
# 1. Construir el proyecto
npm run build

# 2. Configurar variables de entorno en el servidor
NODE_ENV=production
DATABASE_CLIENT=postgres  # o mysql
# ... otras variables
```

#### Opciones de Hosting

- **Strapi Cloud**: Hosting oficial optimizado
- **Heroku**: [Guía de despliegue](https://docs.strapi.io/dev-docs/deployment/heroku)
- **AWS**: EC2, ECS, Lambda
- **DigitalOcean**: Droplets o App Platform
- **Docker**: Containerización

Ver más opciones en la [documentación oficial de despliegue](https://docs.strapi.io/dev-docs/deployment).

## Recursos

### Documentación Oficial

- [Strapi Documentation](https://docs.strapi.io) - Documentación completa
- [REST API Reference](https://docs.strapi.io/dev-docs/api/rest) - Referencia de la API REST
- [CLI Reference](https://docs.strapi.io/dev-docs/cli) - Comandos disponibles
- [Plugin Development](https://docs.strapi.io/dev-docs/plugins-development) - Crear plugins

Desarrollado con Strapi v5.28.0
