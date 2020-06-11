
window.onload = function(){
  
    const ws  = new WebSocket('ws://' + window.location.host );
    this.console.log(ws)
    var show =  function(el){
                  return msg => { el.innerHTML = msg; }
                }(document.getElementById('notification'));

    ws.onopen = () => {console.log('conectado'); }
 
    ws.onmessage = e => {
      msj = e.data;
      show(e.data)
      console.log('update');
    }

    ws.onclose = e => {
      console.log('desconectado');
      console.log(e);
    }
    
    ws.onerror = e => { console.log('erro:'+e); }

    function inputReset(ws) {
      var btn_notification = document.getElementById('btn_notyf');
      btn_notification.addEventListener('click', e => {
        var notification = (document.getElementById('notification'));
        console.log('anda')
        notification.innerHTML = '0'  
        ws.send('0');
      })
      return false;
      
    }
   
}
