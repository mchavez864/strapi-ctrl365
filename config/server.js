// ./config/server.js

module.exports = ({ env }) => ({
  host: env('HOST', '0.0.0.0'),
  port: env.int('PORT', 1337),
  app: {
    // Usamos el secreto STRAPI_APP_KEYS como arreglo
    keys: env.array('STRAPI_APP_KEYS'),
  },
  webhooks: {
    populateRelations: env.bool('WEBHOOKS_POPULATE_RELATIONS', false),
  },
  admin: {
    auth: {
      secret: env('ADMIN_STRAPI_JWT_SECRET'),
    },
  },
  // JWT para API
  jwt: {
    secret: env('STRAPI_JWT_SECRET'),
  },
});

