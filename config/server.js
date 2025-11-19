// config/server.js
module.exports = ({ env }) => ({
  host: env("HOST", "0.0.0.0"),
  port: env.int("PORT", 1337),
  app: {
    // Entra desde APP_KEYS, que en Azure va a venir de STAGING_STRAPI_APP_KEYS
    keys: env.array("APP_KEYS"),
  },
});
