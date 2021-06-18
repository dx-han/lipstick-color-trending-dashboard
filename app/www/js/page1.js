var zr = null;
var bgDpi = 1;
var zrDpi = 1;
var width = 0;
var height = 0;
var colorFromJson = null;
var clock = 0;
var rgba = null;
var nearColor = null;
var notNormalGroups = [];


// $(document).ready(function () {
//     $('#page2-palette').dblclick(function (event) {
//         x = event.offsetX;
//         y = event.offsetY;
//         bgp2 = document.getElementById('bgp2');
//         ctx = bgp2.getContext('2d');
//         var pixel = ctx.getImageData(x, y, 1, 1);
//         var data = pixel.data;
//         var rgbShiny = data[0] + ',' + data[1] + ',' + data[2];
//         Shiny.onInputChange("pagetwo-paletteCustomColor", rgbShiny);
//     })
// })


function page1InitPaletteBackground(hsbRange) {
    width = Math.floor(window.innerWidth * 0.35);
    height = Math.floor(window.innerHeight * 0.65);
    console.log("background", width, height);

    var bgDom = document.getElementById('p1bg');
    bgDom.setAttribute('width', width);
    bgDom.setAttribute('height', height);

    var hsbRange = hsbRange.split(',');
    minMax = {
        'hue': parseFloat(hsbRange[0]),
        'saturationMin': parseFloat(hsbRange[1]),
        'saturationMax': parseFloat(hsbRange[2]),
        'brightMin': parseFloat(hsbRange[3]),
        'brightMax': parseFloat(hsbRange[4])
    };

    console.log(minMax);
    page1RenderBackground(bgDom, minMax);
    // $(function() {
    //     page1RenderBackground(bgDom, minMax);
    // });
}


function page1RenderBackground(bgDom, minMax) {
    var ctx = bgDom.getContext('2d');
    var imgData = ctx.createImageData(width, height);
    var data = imgData.data;
    
    for (var y = 0; y < height; ++y) {
        for (var x = 0; x < width; ++x) {
            var bright = (height - y) / height * (minMax.brightMax - minMax.brightMin) + minMax.brightMin;
            var saturation = x / width * (minMax.saturationMax - minMax.saturationMin) + minMax.saturationMin;
            var color = tinycolor({
                h: minMax.hue,
                s: saturation,
                v: bright
            });
            var rgb = color.toRgb();
            var id = (y * width + x) * 4;
            data[id] = rgb.r;
            data[id + 1] = rgb.g;
            data[id + 2] = rgb.b;
            data[id + 3] = 255;
        }
    }
    ctx.putImageData(imgData, 0, 0);
}


function page1InitDataPointsOnPalette(hsbRange, colorRawSet) {
    width = Math.floor(window.innerWidth * 0.35);
    height = Math.floor(window.innerHeight * 0.65);
    console.log("point", width, height);

    var zrDom = document.getElementById('p1zr');
    zrDom.style.width = width + 30 + 'px';
    zrDom.style.height = height + 30 + 'px';
    zr = zrender.init(zrDom, width=width, height=height);

    var colorSplitRawSet = colorRawSet.split(',');
    colorSet = [];
    for (var count = 0; count < colorSplitRawSet.length; ++count) {
        colorInfo = {'color': colorSplitRawSet[count].slice(0,7), 'name': colorSplitRawSet[count].slice(7)}
        colorSet = colorSet.concat(colorInfo);
    }

    var hsbRange = hsbRange.split(',');
    minMax = {
        'hue': parseFloat(hsbRange[0]),
        'saturationMin': parseFloat(hsbRange[1]),
        'saturationMax': parseFloat(hsbRange[2]),
        'brightMin': parseFloat(hsbRange[3]),
        'brightMax': parseFloat(hsbRange[4])
    };

    console.log(colorSet);
    page1AddHsvToColorSet(colorSet);
    page1RenderDataPoints(colorSet, minMax);
    // $(function() {
    //     page1AddHsvToColorSet(colorSet);
    //     page1RenderDataPoints(colorSet, minMax);
    // });
}


function page1RenderDataPoints(colorSet, minMax) {
    for (var i = 0; i < colorSet.length; ++i) {
        var coord = page1GetDataCoord(colorSet[i], minMax);
        var pos = [coord.x * zrDpi, coord.y * zrDpi];
        var rgbVal = tinycolor(colorSet[i].color).toRgb();
        console.log(coord);
        console.log(rgbVal);
        var point = new zrender.Circle({
            shape: {
                cx: 0,
                cy: 0,
                r: 5
            },
            style: {
                fill: 'rgb(' + rgbVal.r + ',' + rgbVal.g + ',' + rgbVal.b + ')',
                stroke: 'rgba(255, 255, 255, 1)',
                lineWidth: 1,
                text: colorSet[i].name + '\n' + 'rgb(' + rgbVal.r + ',' + rgbVal.g + ',' + rgbVal.b + ')',
                fontSize: 12,
                textAlign: 'center',
                textVerticalAlign: 'middle',
                textFill: 'rgba(255, 255, 255, 1)',
                textOffset: [0, 20]
            },
            position: pos,
            z: 1
        });

        var group = new zrender.Group();
        group.add(point);
        zr.add(group);
    }
    
    zr.on('mousemove', hover);
    zr.on('click', page1PostPointToShiny);
    
}


function page1AddHsvToColorSet(colorSet) {
    for (var i = 0; i < colorSet.length; ++i) {
        var hsv = tinycolor(colorSet[i].color).toHsv();
        colorSet[i]._hsv = hsv;
    }
}


function page1GetDataCoord(data, minMax) {
    var saturation = data._hsv.s;
    var bright = data._hsv.v;
    return {
        x: (saturation - minMax.saturationMin) * width / (minMax.saturationMax - minMax.saturationMin) / bgDpi,
        y: height / bgDpi - (bright - minMax.brightMin) * height / (minMax.brightMax - minMax.brightMin) / bgDpi
    };
}


function page1PostPointToShiny(el) {
    if (el.target) {
        Shiny.onInputChange("pageoneanalysis-loadColor", el.target.style.text);
    }
}


function hover(el) {
    if (!el.target) {
        normal(notNormalGroups);
        notNormalGroups = null;
        return;
    }
    
    group = el.target;
    emphasis(group);
    notNormalGroups = group;
}


function emphasis(group) {
    var point = group;
    point.attr('z', 11);
    point.stopAnimation(true);
    point.animateTo({
        shape: {
            r: 10
        },
        style: {
            lineWidth: 3,
            stroke: '#fff',
            shadowBlur: 20,
            shadowColor: 'rgba(0, 0, 0, 0.4)',
            fontSize: 15,
            textOffset: [0, 30]
        }
    }, 200, 0, 'bounceOut');
}


function normal(group) {
    var point = group;
    point.attr('z', 1);
    point.stopAnimation(true);
    point.animateTo({
        shape: {
            r: 5
        },
        style: {
            stroke: 'rgba(255, 255, 255, 0.8)',
            lineWidth: 1,
            shadowBlur: 0,
            fontSize: 12,
            textOffset: [0, 20]
        }
    }, 200, 0, 'linear');
}
