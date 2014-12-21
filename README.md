# Create tile map from SVG Tokyo rail map

- [Tokyo rail map](http://note.openvista.jp/2014/svg-rail-map)

# How to use

1. Copy tokyo.svg from [Tokyo rail map](https://github.com/hashcc/railmaps) in current directory.
2. setup and run

## for ruby

Install [M+ OUTLINE FONTS](mplus-fonts.sourceforge.jp/mplus-outline-fonts/download/index.html), Cairo, libRSVG, Pango, ImageMagick.

and

```
bundle install --path vendor/bundle
bundle exec ruby make_tiles.rb
open site_rb/index.html
```

## for PhantomJS

```
phantomjs make_tiles.js
open site_js/index.html
```

# License

MIT License.
