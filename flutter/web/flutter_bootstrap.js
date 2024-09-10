{{flutter_js}}
{{flutter_build_config}}

const loading = document.createElement('div');
document.body.appendChild(loading);
loading.textContent = "Loading Entrypoint...";
_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
//    loading.textContent = "Initializing engine...";
    loading.classList.add('main_done');
    const appRunner = await engineInitializer.initializeEngine();

//    loading.textContent = "Running app...";
    loading.classList.add('init_done');
    await appRunner.runApp();
  },
  serviceWorkerSettings: {
      serviceWorkerVersion: {{flutter_service_worker_version}},
    },
});