
console.log("socket")

 window.onload = function(){
    const ws  = new WebSocket('ws://' + window.location.host + window.location.pathname);
    
    var show =  function(el){
                  return msg => { el.innerHTML = msg + '<br />' + el.innerHTML; }
      
                }(document.getElementById('msg'));


    ws.onopen = () => {console.log('conectado'); }

    ws.onmessage = e => {
      msj = e.data;
      show(e.data)
      console.log(msj);
    }

    ws.onclose = e => {
      console.log('desconectado');
      console.log(e);
    }
    
    ws.onerror = e => { console.log('erro:'+e); }

    this.inputReset(ws);
}

function inputReset(ws) {
  var input = document.getElementById('input');
  input.addEventListener('click', () => { input.value = '' } );
  var form = document.getElementById('form');
  form.onsubmit = e => {
    ws.send(input.value);
    input.value = "Escribe algo..";
    return false;
  }
}
