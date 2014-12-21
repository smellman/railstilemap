var page = require('webpage').create(),
    system = require('system'),
    fs = require('fs');

var basezoom = 13;
var minzoom = 8;
var maxzoom = 14;
var tile_size = 256;
var svgfile = "tokyo.svg";

var get_scale = function(zoom) {
    return Math.pow(2, zoom - basezoom);
};

var build_tile = function(obj, size, zoom) {
    var scale = get_scale(zoom);
    obj.zoomFactor = scale;
    var start_column = 0;
    var row = 0;
    var column = 0;
    var to_x = size.width * scale;
    var to_y = size.height * scale;
    var start_x = 0;
    var start_y = 0;

    var rect = { top: start_y, left: start_x, width: tile_size, height: tile_size };
    while (true) {
        if (rect.left > to_x) {
            rect.left = start_x;
            rect.top = rect.top + rect.height;
            column = start_column;
            row = row + 1;
        }
        if (rect.top > to_y) {
            break;
        }
        var filename = "site_js" + fs.separator + "tile" + fs.separator + zoom + fs.separator + column + "_" + row + ".png";
        //console.log(filename);
        page.clipRect = rect;
        page.render(filename);
        rect.left = rect.left + rect.width;
        column = column + 1;
    }
};

var run = function() {
    page.open(svgfile, function(status) {
        if (status !== 'success') {
            console.log('Unable to load the address: ' + svgfile);
            phantom.exit();
        } else {
            window.setTimeout(function() {
                var baseVal = page.evaluate(function() {
                    return document.rootElement.viewBox.baseVal;
                });
                var size = {
                    "width": baseVal.width,
                    "height": baseVal.height
                };
                for (var zoom = minzoom; zoom <= maxzoom; zoom++) {
                    build_tile(page, size, zoom);
                }
                phantom.exit();
            }, 200);
        }
    });
};

var make_directory = function(dir_path) {
    if (!fs.isDirectory(dir_path)) {
        if (!fs.makeDirectory(dir_path)) {
            console.log("can't makedirectory: " + dir_path);
            phantom.exit();
        }
    }
};

var make_directories = function() {
    make_directory("site_js" + fs.separator + "tile");
    for (var zoom = minzoom; zoom <= maxzoom; zoom++) {
        var dir = "site_js" + fs.separator + "tile" + fs.separator + zoom;
        make_directory(dir);
    }
};

make_directories();
run();
