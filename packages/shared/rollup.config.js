import typescript from 'rollup-plugin-typescript2';
import pkg from './package.json';

export default {
  input: {
    'integration-events': 'integration-events/index.ts',
    logging: 'logging/index.ts',
    'moderator-actions': 'moderator-actions/index.ts',
    utilities: 'utilities/index.ts',
  },
  output: {
    dir: 'dist',
    file: pkg.main,
    entryFileNames: '[name]/index.js',
    format: 'cjs',
    exports: 'named',
  },
  plugins: [typescript()],
  external: ['react'],
};
