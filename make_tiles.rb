# coding: utf-8
require 'rsvg2'
require 'tmpdir'
require 'tempfile'
require 'pango'

TILESIZE=256
MINZOOM=8
MAXZOOM=14
BASEZOOM=13

def svg2png(filepath, output_file, scale)
  Pango::CairoFontMap.default = Pango::CairoFontMap.create(:freetype)
  handle = RSVG::Handle.new_from_file(filepath)
  ratio = scale
  _width = (handle.dimensions.width * ratio).to_i
  _height = (handle.dimensions.height * ratio).to_i
  surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, _width, _height)
  context = Cairo::Context.new(surface)
  context.scale(ratio, ratio)
  context.render_rsvg_handle(handle)
  surface.write_to_png(output_file)
  return _width, _height
end

def make_tile(file, tile_dir, zoom)
  basename = File.basename(file, ".svg")
  output_dir = File.join(tile_dir, zoom.to_s)
  unless Dir.exist?(output_dir)
    Dir.mkdir(output_dir)
  end

  Dir.mktmpdir do |working_dir|
    png_file = Tempfile.new(["svg", ".png"])
    png_file.close
    scale = 2 ** (zoom - BASEZOOM)
    width, height = svg2png(file, png_file.path, scale)
    tilebase = File.join(working_dir, "#{basename}_%d.png")
    tiles_per_column = (width.to_i/TILESIZE) + 1
    tiles_per_row = (height.to_i/TILESIZE) + 1
    bg_width = tiles_per_column * TILESIZE
    bg_height = tiles_per_row * TILESIZE
    bg_file = Tempfile.new(["bg", ".png"])
    bg_file.close
    `convert -size #{bg_width.to_s}x#{bg_height.to_s} xc:none #{bg_file.path}`
    new_file = Tempfile.new(["new", ".png"])
    new_file.close
    `convert #{bg_file.path} #{png_file.path} -gravity northwest -geometry +#{0}+#{0} -composite #{new_file.path}`
    `convert -crop #{TILESIZE}x#{TILESIZE} +repage #{new_file.path} #{tilebase}`
    png_file.delete
    bg_file.delete
    new_file.delete
    total_tiles = Dir[File.join(working_dir, "#{basename}_*.png")].length
    n = 0
    row = 0
    column = 0
    (n...total_tiles).each do |i|
      filename = File.join(working_dir, "#{basename}_#{i}.png") # current filename
      target = File.join(tile_dir, zoom.to_s, "#{column}_#{row}.png") # new filename
      `cp -f #{filename} #{target}` # rename
      column = column + 1
      if column >= tiles_per_column
        column = 0
        row = row + 1
      end
    end
  end
end



if __FILE__ == $0
  file = 'tokyo.svg'
  tile_dir = 'site_rb/tile'
  unless Dir.exist?(tile_dir)
    Dir.mkdir(tile_dir)
  end
  (MINZOOM..MAXZOOM).each do |zoom|
    make_tile(file, tile_dir, zoom)
  end
end
