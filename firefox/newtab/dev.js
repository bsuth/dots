#!/usr/bin/env node

const fse = require('fs-extra');
const chokidar = require('chokidar');
const esbuild = require('esbuild');
const sass = require('sass');

function build() {
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
}

process.argv[2] === '--watch'
  ? chokidar.watch('src').on('change', path => {
      console.log(`Changes detected: ${path}, rebuilding...`);
      build();
    })
  : build();
