
window.onload =  e => {
    console.log("anda");
    document.getElementById('send').addEventListener('click',validate,false);

}

function validateDni() {
    var dni = document.getElementById("dni");

    if(!dni.checkValidity()){
        if (dni.validity.patternMismatch)
            warning(dni,"Ingrese un Dni valido");
        else 
            warning(dni,"Ingrese su Dni");
        
        return false;
    }
    return true;

}

function validateEmail() {
    var email = document.getElementById("email");

    if(!email.checkValidity()){

        if (email.validity.patternMismatch)
            warning(email,"Ingrese un direccion de correo valida");
        else 
            warning(email,"Ingrese una direccion de correo");

        return false;
    }
    return true;

}

function validatePassword() {
    var pwd = document.getElementById("pwd");

    if(!pwd.checkValidity()){
        if (pwd.validity.patternMismatch)
            warning(pwd,"Ingrese una contraseña valida, mínimo de ocho caracteres, al menos una letra mayúscula, una letra minúscula y un número");
        else 
            warning(pwd,"Ingrese una contraseña");
        return false;
    }
    return true;

}

function validateName() {
    var name = document.getElementById("name");

    if(!name.checkValidity()){
        warning(name,"Ingrese un nombre");
        return false;
    }
    return true;

}

function validateLastname() {
    var lastname = document.getElementById("lastname");

    if(!lastname.checkValidity()){
        warning(lastname,"Ingrese un apellido");
        return false;
    }
    return true;

}

function validate(e) {
    resetWarning();
    if ( validateDni() && validateName() && validateLastname() && 
            validateEmail() && validatePassword() )
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
    var form = document.forms[0];
    for (let i = 0; i < form.elements.length-1; i++){
        const elem = form.elements[i];
        const elemParent = form.elements[i].parentNode;
        elem.classList.remove( "w3-border-red");
       
        if(elemParent.children.length > 2){
            var lastChild = elemParent.lastChild;
            elemParent.removeChild(lastChild);
        }
        
        

    } 
        

}

