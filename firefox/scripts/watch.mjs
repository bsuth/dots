import * as esbuild from 'esbuild'

const backgound_context = await esbuild.context({
  entryPoints: ['./background/index.ts'],
  bundle: true,
  outfile: 'build/background.js',
})

const content_context = await esbuild.context({
  entryPoints: ['./content/index.ts'],
  bundle: true,
  outfile: 'build/content.js',
})

await backgound_context.watch()
await content_context.watch()
