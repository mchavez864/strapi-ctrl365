// src/admin/vite.config.js

const { mergeConfig } = require('vite');

module.exports = (config) => {
  // Siempre devolver el config mergeado
  return mergeConfig(config, {
    server: {
      // Opción 1: permitir solo este host
      allowedHosts: ['strapi.ctrl365.com'],

      // Opción 2 (más relajada, si querés para dev):
      // allowedHosts: true,
    },
  });
};

