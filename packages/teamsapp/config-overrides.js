module.exports = function override(config, env) {
  console.log('override polyfill config');
  const resolve = config.resolve;
  resolve.fallback = {
    // existing configs...
    assert: require.resolve('assert/'),
    fs: false,
    os: require.resolve('os-browserify/browser'),
    http: require.resolve('stream-http'),
    https: require.resolve('https-browserify'),
    path: require.resolve('path-browserify'),
    stream: require.resolve('stream-browserify'),
    url: require.resolve('url/'),
    zlib: require.resolve('browserify-zlib'),
  };

  return config;
};
