// config/server.js
module.exports = ({ env }) => ({
  host: env("HOST", "0.0.0.0"),
  port: env.int("PORT", 1337),
  app: {
    // Usamos APP_KEYS, que es lo que tenés en .env.example y en los secrets
    keys: env.array("APP_KEYS"),
  },
});
