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


function extractColorFromJson(rawData) {
    colorFromJson = [];
    for (var bid = 0, blen = rawData.brands.length; bid < blen; ++bid) {
        var brand = rawData.brands[bid];
        for (var sid = 0, slen = brand.series.length; sid < slen; ++sid) {
            var lipsticks = brand.series[sid].lipsticks;
            colorFromJson = colorFromJson.concat(lipsticks);
            for (var lid = 0, llen = lipsticks.length; lid < llen; ++lid) {
                lipsticks[lid].series = brand.series[sid];
                lipsticks[lid].brand = brand;
            }
        }
    }
}


function getMinMax(colorFromJson) {
    var minHue = Number.MAX_VALUE;
    var maxHue = Number.MIN_VALUE;
    var minLight = Number.MAX_VALUE;
    var maxLight = Number.MIN_VALUE;
    for (var i = 0; i < colorFromJson.length; ++i) {
        var hsl = tinycolor(colorFromJson[i].color).toHsl();
        hsl.l *= 100;
        colorFromJson[i]._hsl = hsl;

        var hue = encodeHue(hsl.h);
        if (hue < 165 || hue > 220) {
            // ignore rare colors
            continue;
        }

        if (hue > maxHue) {
            maxHue = hue;
        }
        if (hue < minHue) {
            minHue = hue;
        }

        var light = hsl.l;
        if (light > maxLight) {
            maxLight = light;
        }
        if (light < minLight) {
            minLight = light;
        }
    }
    return {
        minHue: minHue - 2,
        maxHue: maxHue + 2,
        minLight: Math.max(minLight - 10, 0),
        maxLight: Math.min(maxLight + 5, 100)
    };
}


function initPaletteBackground() {
    width = Math.floor(window.innerWidth * 0.64);
    height = Math.floor(window.innerHeight * 0.78);
    console.log("background", width, height);

    var bgDom = document.getElementById('bgp2');
    bgDom.setAttribute('width', width);
    bgDom.setAttribute('height', height);
    // bgDom.style.position = 'fixed';

    $.getJSON('data/palette.json', function (data) {
        extractColorFromJson(data);

        var minMax = getMinMax(colorFromJson);
        renderBackground(bgDom, minMax);
    });
}


function renderBackground(bgDom, minMax) {
    var ctx = bgDom.getContext('2d');
    var imgData = ctx.createImageData(width, height);
    var data = imgData.data;

    for (var y = 0; y < height; ++y) {
        for (var x = 0; x < width; ++x) {
            var light = (height - y) / height * (minMax.maxLight - minMax.minLight) + minMax.minLight;
            var hue = x / width * (minMax.maxHue - minMax.minHue) + minMax.minHue;
            var color = tinycolor({
                h: encodeHue(hue),
                s: 80,
                l: light
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


function initDataPointsOnPalette(colorRawSet, customColor, whichTab = 1) {
    width = Math.floor(window.innerWidth * 0.64);
    height = Math.floor(window.innerHeight * 0.78);
    console.log("point", width, height);

    var zrDom = document.getElementById('zr');
    zrDom.setAttribute('width', width * zrDpi);
    zrDom.setAttribute('height', height * zrDpi);
    zr = zrender.init(zrDom);

    var colorSplitRawSet = colorRawSet.split(',');
    colorSet = [];
    for (var count = 0; count < colorSplitRawSet.length; ++count) {
        colorInfo = {'color': colorSplitRawSet[count].slice(0,7), 'name': colorSplitRawSet[count].slice(7)}
        colorSet = colorSet.concat(colorInfo);
    }

    colorSet = colorSet.concat({
        'color': customColor,
        'name': '自选色'
    })

    console.log(colorSet)

    $.getJSON('data/palette.json', function (data) {
        extractColorFromJson(data);
        var minMax = getMinMax(colorFromJson);

        addHslToColorSet(colorSet);
        renderDataPoints(colorSet, minMax, whichTab);
    });
}


function showSimilarityPoint(lipstickData) {
    color1 = hexToRgb(lipstickData[0].color);
    color2 = hexToRgb(lipstickData[1].color);
    res = Math.sqrt((color1.r - color2.r)**2 + (color1.g - color2.g)**2 + (color1.b - color2.b)**2);
    var simDom = document.getElementById('sim');
    simDom.style.position = "absolute";
    simDom.style.visibility = "visible";
    simDom.style.marginTop = "10px";
    simDom.style.marginLeft = Math.floor((window.innerWidth - document.getElementById('page2-slide').offsetWidth) / 2) - 100 + 'px';
    simDom.innerText = "颜色相似度: " + Math.floor(res);
}


function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
  }


function addHslToColorSet(colorSet) {
    for (var i = 0; i < colorSet.length; ++i) {
        var hsl = tinycolor(colorSet[i].color).toHsl();
        hsl.l *= 100;
        colorSet[i]._hsl = hsl;
        var hue = encodeHue(hsl.h);
    }
}


function renderDataPoints(colorSet, minMax, whichTab, nearColor) {
    for (var i = 0; i < colorSet.length; ++i) {
        var coord = getDataCoord(colorSet[i], minMax);
        var pos = [coord.x * zrDpi, coord.y * zrDpi];
        var rgbVal = hexToRgb(colorSet[i].color);
        var point = new zrender.Circle({
            shape: {
                cx: 0,
                cy: 0,
                r: 5
            },
            style: {
                fill: 'rgba(255, 255, 255, 0)',
                stroke: 'rgba(255, 255, 255, 0.8)',
                lineWidth: 1,
                text: colorSet[i].name + '\n' + 'rgb(' + rgbVal.r + ',' + rgbVal.g + ',' + rgbVal.b + ')',
                fontSize: 12,
                textAlign: 'center',
                textVerticalAlign: 'middle',
                textFill: 'rgba(255, 255, 255, 0.5)',
                textOffset: [0, 20]
            },
            position: pos,
            z: 1
        });

        // if (colorSet[i].name == '自选色') {
        //     point.style.fill = 'rgba(255, 255, 255, 0)';
        //     point.style.textFill = 'rgba(27, 94, 32, 0.8)',
        // }

        if (whichTab == 3 && i == 0) {
            point.style.fill = 'rgba(255, 255, 255, 1)';
        }

        var group = new zrender.Group();
        group.add(point);
        zr.add(group);

        group.lipstick = colorSet[i];
        group.lipstick.group = group;
    }
    
    zr.on('click', postPointToShiny);
    zr.on('mousemove', hover);
}


function postPointToShiny(el) {
    if (el.target) {
        Shiny.onInputChange("pagetwo-react", el.target.style.text);
    }
}


function getDataCoord(data, minMax) {
    var hue = encodeHue(data._hsl.h);
    var light = data._hsl.l;
    return {
        x: (hue - minMax.minHue) * width / (minMax.maxHue - minMax.minHue) / bgDpi,
        y: height / bgDpi - (light - minMax.minLight) * height / (minMax.maxLight - minMax.minLight) / bgDpi
    };
}


function hover(el) {
    if (!el.target) {
        normal(notNormalGroups);
        notNormalGroups = [];
        return;
    }
    if (el.target.style.text.split('\n')[0] == '自选色') {
        group = el.target.parent;
        emphasis(group);
        notNormalGroups = [group];
        console.log(nearColor)
        for (var i = 0; i < colorSet.length; ++i) {
            var l = colorSet[i];
            if (l.name == nearColor) {
                emphasis(l.group);
                notNormalGroups.push(l.group)
            }
        }
        
    }
}


function emphasis(group) {
    var point = group.childAt(0);
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


function normal(groups) {
    for (var i = 0; i < groups.length; ++i) {
        var point = groups[i].childAt(0);
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
}


/**
 * convert red hue to be around 0.5
 */
function encodeHue(hue) {
    if (hue < 180) {
        return 180 - hue;
    }
    else {
        return 540 - hue;
    }
}
