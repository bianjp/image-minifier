# Image-minifier

Shell wrapper of [TinyPNG](https://tinypng.com/) API.

TinyPNG is an advanced lossy compression tool for PNG images that preserves full alpha transparency.

## Prerequisite

You must have an [api key](https://tinypng.com/developers) to use TinyPNG API.

TinyPNG provides 500 free compression for each user every month.

Save you key in `api.key`, or just fill it in `minify.sh`.

## Usage

```
./minify.sh [-o output_dir] [file|directory]...
```

If no output directory is supplied, it will replace original files.

## Tips

For convenience, you can add an alias in your ~/.bashrc

```
alias minify_images='[Absolute path to minify.sh]/minify.sh'
```

This way, you can use `minify_images` no matter which directory are you working in.

## License

MIT
