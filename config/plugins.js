// ./config/plugins.js
module.exports = ({ env }) => ({
  upload: {
    config: {
      provider: '@strapi/provider-upload-azure',
      providerOptions: {
        account: env('AZURE_ACCOUNT_NAME'),
        accountKey: env('AZURE_ACCOUNT_KEY'),
        containerName: env('AZURE_CONTAINER_NAME'),
        defaultPath: env('AZURE_DEFAULT_PATH', 'uploads'),
        azureUploadSasToken: env('AZURE_SAS_TOKEN', null), // opcional
        removeContainerName: env('AZURE_REMOVE_CN') === 'true',
        maxConcurrent: 10,
        serviceBaseURL: env('AZURE_SERVICE_BASE_URL', null), // opcional CDN
      },
    },
  },
});

