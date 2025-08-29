// Criado por Luguin
let intervalo;

function verificarServidores() {
    console.log("[DEBUG] Verificando servidores da página...");

    const servidores = document.querySelectorAll(".rbx-public-game-server-details.game-server-details");
    let encontrou = false;

    servidores.forEach((servidor, index) => {
        const status = servidor.querySelector(".rbx-public-game-server-status");
        if (status) {
            const texto = status.innerText;
            const match = texto.match(/Region:\s*(.+)/);
            const regiao = match ? match[1] : "Não encontrado";

            console.log(`[Servidor ${index+1}] Região:`, regiao);

            if (regiao === "Unknown") {
                alert("server br pego");
                clearInterval(intervalo);
                encontrou = true;
            }
        }
    });


    if (!encontrou) {
        const nextButton = document.querySelector(".btr-pager-next button");
        if (nextButton) {
            console.log("[DEBUG] Nenhum servidor BR encontrado. Indo para a próxima página...");
            nextButton.click();
        } else {
            console.warn("[DEBUG] Botão Next não encontrado. Pode ser a última página.");
            clearInterval(intervalo);
        }
    }
}

function iniciarBusca() {
    intervalo = setInterval(verificarServidores, 1500); 
    console.log("[DEBUG] Busca iniciada...");
}

iniciarBusca();
