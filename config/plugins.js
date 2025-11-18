// ./config/plugins.js
export default ({ env }) => ({
  upload: {
    config: {
      provider: 'azure-storage',
      providerOptions: {
        account: env('AZURE_ACCOUNT_NAME'),       // webctrl365sa
        accountKey: env('AZURE_ACCOUNT_KEY'),     // clave del storage account
        containerName: env('AZURE_CONTAINER_NAME'), // staging
        defaultPath: env('AZURE_DEFAULT_PATH', 'uploads'), // uploads
        azureUploadSasToken: env('AZURE_SAS_TOKEN', null), // opcional
        removeContainerName: env('AZURE_REMOVE_CN') === 'true',
        maxConcurrent: 10, // opcional: número de uploads simultáneos
        serviceBaseURL: env('AZURE_SERVICE_BASE_URL', null) // opcional si usas CDN
      },
    },
  },
});

