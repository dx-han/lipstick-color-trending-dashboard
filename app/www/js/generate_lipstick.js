


function generate_color() {
    var img = new Image();
    
    img.src = 'img/lipstick.png';
    img.crossOrigin = 'Anonymous';
    // img = document.getElementById('image');
    // img.crossOrigin = 'Anonymous';
    console.log(img.src);
    let src = cv.imread(img);
    console.log(src.cols);
    res = rgb2lab([100,100,100]);
}



// $(document).ready(function () {
//     $('#modal1').modal({
//         onOpenEnd() {
//             Shiny.addCustomMessageHandler("cpath", function(colorFilePath) {
//                 console.log('mode', colorFilePath)
//                 var img = new Image();
//                 img.src = 'img/tmp/' + colorFilePath;
//                 img.crossOrigin = 'Anonymous';
//                 divWidth = document.getElementById('picload').offsetWidth - 20;
//                 var colorHover = document.getElementById('color-hover');
//                 var textHover = document.getElementById('text-hover');
//                 var picbg = document.getElementById('picbg');
//                 var colorClick = document.getElementById('color-click');
//                 var textClick = document.getElementById('text-click');
//                 var showTip = document.getElementById('show-tip');
    
//                 img.onload = function() {
//                     divHeight = Math.floor(this.naturalHeight * divWidth / this.naturalWidth);
//                     picbg.width = divWidth;
//                     picbg.height = divHeight;
//                     var ctx = picbg.getContext('2d');
//                     ctx.drawImage(this, 0, 0, divWidth, divHeight);
//                     function pick(event) {
//                         var x = event.layerX;
//                         var y = event.layerY;
        
//                         var pixel = ctx.getImageData(x, y, 1, 1);
//                         var data = pixel.data;
        
//                         var rgbValue = 'rgb(' + data[0] + ',' + data[1] +',' + data[2] + ')';
//                         colorHover.style.background = rgbValue;
//                         colorHover.style.width = 30 + 'px';
//                         colorHover.style.height = 30 + 'px';
//                         textHover.textContent = rgbValue;
//                     }
//                     function save(event) {
//                         var x = event.layerX;
//                         var y = event.layerY;
    
//                         var pixel = ctx.getImageData(x, y, 1, 1);
//                         var data = pixel.data;
    
//                         var rgbValue = 'rgb(' + data[0] + ',' + data[1] +',' + data[2] + ')';
//                         var rgbShiny = data[0] + ',' + data[1] + ',' + data[2];
//                         colorClick.style.background = rgbValue;
//                         colorClick.style.width = 30 + 'px';
//                         colorClick.style.height = 30 + 'px';
//                         textClick.textContent = rgbValue;
//                         showTip.textContent = '颜色已保存';
                        
//                         console.log('upload.js', rgbValue, rgbShiny);
//                         Shiny.onInputChange("pagetwo-paletteCustomColor", rgbShiny);
//                     }
//                     picbg.addEventListener('mousemove', pick);
//                     picbg.addEventListener('click', save);
//                 };
//             });
            
//         }
//     });
// })

