#!/usr/bin/env node

const fse = require('fs-extra');
const esbuild = require('esbuild');
const sass = require('sass');

fse.mkdirSync('build', { recursive: true });
fse.copySync('src/index.html', 'build/index.html');

esbuild.build({
  entryPoints: ['src/main.js'],
  outfile: 'build/main.js',
  bundle: true,
});

fse.writeFileSync(
  'build/styles.css',
  sass
    .renderSync({
      file: 'src/styles.scss',
      outputStyle: 'compressed',
    })
    .css.toString()
);
