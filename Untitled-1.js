// Criado por Luguin

const labelElement = document.querySelector("#rbx-running-games > div.container-header > div.server-list-options > div.checkbox > label");

try {
    let intervalo;

    function verificarUnk(texto) {
        const inputElement = document.querySelector("#rbx-running-games > div.btr-pager-holder.btr-server-pager > ul > li.btr-pager-mid > input");
        if (texto.includes("Unknown") && inputElement) {
            const inputValue = inputElement.value;
            alert("Sv Br encontrado! Página: " + inputValue);
            clearInterval(intervalo);  
        } else {
            const nextButton = document.querySelector("#rbx-running-games > div.btr-pager-holder.btr-server-pager > ul > li.btr-pager-next > button");
            if (nextButton) {
                nextButton.click();
            }
            console.log("Nada encontrado.");
        }
    }

    function iniciarVerificacao() {
        intervalo = setInterval(() => {
            const textoAtualizado = document.body.innerText;
            verificarUnk(textoAtualizado);
        }, 1000);
    }

    function carregarEstiloExtensao(extensionId) {
        return new Promise((resolve, reject) => {
            const link = document.createElement('link');
            link.href = `chrome-extension://${extensionId}/css/main.css`;  
            link.rel = 'stylesheet';
            link.onload = resolve;
            link.onerror = () => reject(new Error("Extensão não instalada."));
            document.head.appendChild(link);
        });
    }

    function configurarCheckbox() {
        if (labelElement && !labelElement.checked) {
            labelElement.click();
        }
    }

    async function iniciarScript() {
        try {
            await carregarEstiloExtensao('hbkpclpemjeibhioopcebchdmohaieln');
            iniciarVerificacao();
        } catch (error) {
            alert(error.message);
        }
    }

    if (sessionStorage.getItem('reloadAfterError') === 'true') {
        sessionStorage.removeItem('reloadAfterError');
        configurarCheckbox();
    }

    configurarCheckbox();
    iniciarScript();

} catch (error) {
    alert("Ocorreu um erro, recarregando a página...");
    sessionStorage.setItem('reloadAfterError', 'true');
    location.reload(); 
}
