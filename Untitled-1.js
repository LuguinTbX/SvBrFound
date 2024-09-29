// Criado por Luguin

const labelElement = document.querySelector("#rbx-running-games > div.container-header > div.server-list-options > div.checkbox > label");

try {
    let todoTexto = document.body.innerText;
    let intervalo;


    function verificarUnk(texto) {
        let inputElement = document.querySelector("#rbx-running-games > div.btr-pager-holder.btr-server-pager > ul > li.btr-pager-mid > input");
        if (texto.includes("Unknown") && inputElement) {
            let inputValue = inputElement.value;
            alert("Sv Br encontrado! Page: " + inputValue);  
            clearInterval(intervalo);  
        } else {
            console.log("Nada encontrado.");
        }
    }


    function checkExtension(extensionId) {
        const link = document.createElement('link');
        link.href = `chrome-extension://${extensionId}/css/main.css`;  
        link.rel = 'stylesheet';
        link.onload = function() {

            intervalo = setInterval(function() {
                let textoAtualizado = document.body.innerText;
                verificarUnk(textoAtualizado);
            }, 1000);
        };
        link.onerror = function() {
            alert("Extensão não instalada."); 
        };
        document.head.appendChild(link);
    }

   
    if (sessionStorage.getItem('reloadAfterError') === 'true') {
        sessionStorage.removeItem('reloadAfterError'); 

        
        if (labelElement && !labelElement.checked) {
            labelElement.click();
        }

     
        checkExtension('hbkpclpemjeibhioopcebchdmohaieln'); 

    } else {
       
        if (labelElement && !labelElement.checked) {
            labelElement.click();
        }

    
        checkExtension('hbkpclpemjeibhioopcebchdmohaieln');
    }

} catch (error) {

    alert("Ocorreu um erro, recarregando a página...");
    sessionStorage.setItem('reloadAfterError', 'true');  
    location.reload(); 
}
