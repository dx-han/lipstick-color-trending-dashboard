$(document).ready(function () {
    p = document.getElementsByClassName("container-fab")[0];
    o = document.getElementsByClassName("shinyadmin")[0];
    if (p.innerHTML.indexOf('.shinymanager_admin') != -1) {
        o.outerHTML = "<div class=\"fixed-action-btn\" style=\"right:15px;top:0px;\"><a class=\"btn-flat waves-effect waves-light shiny-bound-input action-button\" id=\".shinymanager_admin\"><i class=\"material-icons\" style=\"color: #fff;\">supervisor_account</i></a><a class=\"btn-flat waves-effect waves-light shiny-bound-input action-button\" id=\".shinymanager_logout\"><i class=\"material-icons\" style=\"color: #fff;\">keyboard_tab</i></a></div>";
    } else {
        o.outerHTML = "<div class=\"fixed-action-btn\" style=\"right:15px;top:0px;\"><a class=\"btn-flat waves-effect waves-light shiny-bound-input action-button\" id=\".shinymanager_logout\"><i class=\"material-icons\" style=\"color: #fff;\">keyboard_tab</i></a></div>";
    }
    // $('#modal1').modal({
    //     onOpenEnd() {
    //         Shiny.addCustomMessageHandler("cpath", function(colorFilePath) {
    //             console.log('mode', colorFilePath)
    //             var img = new Image();
    //             img.src = 'img/tmp/' + colorFilePath;
    //             img.crossOrigin = 'Anonymous';
    //             divWidth = document.getElementById('picload').offsetWidth - 20;
    //             var colorHover = document.getElementById('color-hover');
    //             var textHover = document.getElementById('text-hover');
    //             var picbg = document.getElementById('picbg');
    //             var colorClick = document.getElementById('color-click');
    //             var textClick = document.getElementById('text-click');
    //             var showTip = document.getElementById('show-tip');
    
    //             img.onload = function() {
    //                 divHeight = Math.floor(this.naturalHeight * divWidth / this.naturalWidth);
    //                 picbg.width = divWidth;
    //                 picbg.height = divHeight;
    //                 var ctx = picbg.getContext('2d');
    //                 ctx.drawImage(this, 0, 0, divWidth, divHeight);
    //                 function pick(event) {
    //                     var x = event.layerX;
    //                     var y = event.layerY;
        
    //                     var pixel = ctx.getImageData(x, y, 1, 1);
    //                     var data = pixel.data;
        
    //                     var rgbValue = 'rgb(' + data[0] + ',' + data[1] +',' + data[2] + ')';
    //                     colorHover.style.background = rgbValue;
    //                     colorHover.style.width = 30 + 'px';
    //                     colorHover.style.height = 30 + 'px';
    //                     textHover.textContent = rgbValue;
    //                 }
    //                 function save(event) {
    //                     var x = event.layerX;
    //                     var y = event.layerY;
    
    //                     var pixel = ctx.getImageData(x, y, 1, 1);
    //                     var data = pixel.data;
    
    //                     var rgbValue = 'rgb(' + data[0] + ',' + data[1] +',' + data[2] + ')';
    //                     var rgbShiny = data[0] + ',' + data[1] + ',' + data[2];
    //                     colorClick.style.background = rgbValue;
    //                     colorClick.style.width = 30 + 'px';
    //                     colorClick.style.height = 30 + 'px';
    //                     textClick.textContent = rgbValue;
    //                     showTip.textContent = '颜色已保存';
                        
    //                     console.log('upload.js', rgbValue, rgbShiny);
    //                     Shiny.onInputChange("pagetwo-paletteCustomColor", rgbShiny);
    //                 }
    //                 picbg.addEventListener('mousemove', pick);
    //                 picbg.addEventListener('click', save);
    //             };
    //         });
            
    //     }
    // });
})

