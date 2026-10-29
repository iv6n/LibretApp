{{flutter_js}}
{{flutter_build_config}}

// Keep the renderer on this origin so the offline shell includes its runtime.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: 'canvaskit/',
    canvasKitVariant: 'full',
  },
});
