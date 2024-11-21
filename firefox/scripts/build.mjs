import * as esbuild from 'esbuild'

esbuild.build({
  entryPoints: ['./background/index.ts'],
  bundle: true,
  outfile: 'build/background.js',
})

esbuild.build({
  entryPoints: ['./content/index.ts'],
  bundle: true,
  outfile: 'build/content.js',
})
