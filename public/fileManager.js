
'use strict'

function getFileExtension(){
    var path = fileInput.value;
    format.value = path.substr(path.lastIndexOf("\\") + 1).split('.')[1];
    console.log(format.value);
    
}