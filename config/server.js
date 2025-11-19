// config/server.js
module.exports = ({ env }) => ({
  host: env("HOST", "0.0.0.0"),
  port: env.int("PORT", 1337),
  app: {
    // Usamos APP_KEYS, igual que en .env.example y en el set-env-vars del workflow
    keys: env.array("APP_KEYS"),
  },
});
