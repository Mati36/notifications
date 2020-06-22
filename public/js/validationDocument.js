
window.onload =  e => {
    console.log("ANDA");
    
   document.getElementById('send').addEventListener('click',validate,false);
}

function validateTitle() {
    var title = document.getElementById("title");

    if(!title.checkValidity()){
        warning(title,"Ingrese un titulo");
        return false;
    }
    return true;

}

function validateArchive() {
    var doc = document.getElementById("doc");

    if(!doc.checkValidity()){
        warning(doc,"Seleccione un documento");
        return false;
    }
    return true;

}

function validate(e) {
    resetWarning();
    if ( validateTitle() && validateArchive() )
        return true;
    else{
         e.preventDefault();
         return false;
    }
}

function warning(e,msg) {
    e.classList.add("w3-border-red");
    var div =  document.createElement("div");
    div.innerHTML = `<p>${msg}</p>`;
    div.className ="w3-text-red w3-myfont";
    e.parentNode.appendChild(div); 
    e.focus();
}

function resetWarning() {
    var form = document.getElementById("validate");
      
    for (let i = 0; i < form.childElementCount - 2; i++){
        const elem = form.children[i];
        
        const elemParent = form.children[i].parentNode;
        elem.classList.remove( "w3-border-red");
       
        if(elemParent.children.length > 2){
            var lastChild = elemParent.lastChild;
            elemParent.removeChild(lastChild);
        }
        
        

    } 
        

}

