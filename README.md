# Atualizador Inteligente para Debian/Ubuntu

![Versão](https://img.shields.io/badge/version-v1.1.0-blue.svg)
![Licença](https://img.shields.io/badge/license-MIT-green.svg)

Um script de shell robusto e inteligente para automatizar o processo de atualização de sistemas baseados em Debian (como Ubuntu), com foco em segurança, clareza e automação.

---

## ✨ Principais Funcionalidades

-   **Ciclo Completo de Atualização**: Executa `update`, `upgrade`, `autoremove` e `autoclean` em um único comando.
-   **Verificação de Conectividade**: Testa a conexão com a internet antes de iniciar para evitar erros de rede.
-   **Seguro por Padrão**:
    -   Verifica se o script é executado com privilégios `root`.
    -   Confirma se o sistema é compatível com `apt`.
    -   Interrompe a execução imediatamente em caso de qualquer erro (`set -e`).
-   **Modo Duplo de Execução**:
    -   **Automático (padrão)**: Perfeito para agendamentos `cron`, executando sem necessidade de intervenção.
    -   **Interativo (`--interactive`)**: Permite revisar a lista de pacotes e confirmar a atualização manualmente.
-   **Relatórios Claros e Inteligentes**:
    -   Exibe uma lista detalhada dos pacotes a serem atualizados, mostrando a mudança de versão (`antiga -> nova`).
    -   Apresenta um resumo final com os pacotes que foram efetivamente alterados, lendo diretamente dos logs do `apt`.
-   **Compatibilidade Universal**: Funciona em sistemas Debian/Ubuntu, independentemente do idioma configurado.
-   **Saída Limpa**: Utiliza cores para facilitar a leitura e suprime logs desnecessários para uma visualização clara do processo.

---

## 📂 Como Usar

### 1. Dê permissão de execução

Torne o script executável com o seguinte comando:
```bash
chmod +x atualizar-sistema.sh
```

### 2. Execução Padrão (Automática)

Para rodar o script de forma direta, sem interrupções. Este é o modo ideal para automações.
```bash
sudo ./atualizar-sistema.sh
```

### 3. Execução Interativa

Para revisar os pacotes e confirmar a atualização manualmente, use a flag `--interactive`:
```bash
sudo ./atualizar-sistema.sh --interactive
```
O script irá listar os pacotes e aguardar sua confirmação (`s` ou `S`) antes de prosseguir.

---

## ⏰ Agendando com Cron

Para manter seu sistema atualizado automaticamente (por exemplo, toda segunda-feira às 3h da manhã), edite o `crontab` do usuário `root`.

1.  Abra o crontab:
    ```bash
    sudo crontab -e
    ```

2.  Adicione a seguinte linha, certificando-se de usar o caminho absoluto para o script:
    ```cron
    # Executa o script de atualização toda segunda-feira às 3h da manhã
    0 3 * * 1 /caminho/completo/para/atualizar-sistema.sh >> /var/log/atualizacoes-sistema.log 2>&1
    ```
    Isso executará o script e salvará um log de sua saída no arquivo `/var/log/atualizacoes-sistema.log`.

---

## 🧪 Exemplo de Saída

```bash
# Atualizador Inteligente v1.1.0
# Desenvolvido por: Paulo Rocha | Copiloto: IA Gemini
# Início da execução: 06/08/2025 16:30:00
# Atualizando a lista de pacotes...
# Verificando pacotes que podem ser atualizados...

# Os seguintes pacotes serão atualizados:

- openssl (3.0.16-1~deb12u1) -> (3.0.17-1~deb12u1)
- libssl3 (3.0.16-1~deb12u1) -> (3.0.17-1~deb12u1)

# Iniciando atualização.

# Instalando atualizações... (Isso pode levar alguns minutos)
# Removendo pacotes desnecessários...
# Limpando o cache de pacotes...

----------------------------------------------------
# Resumo do que foi efetivamente atualizado:
----------------------------------------------------
- openssl:amd64 (3.0.16-1~deb12u1 -> 3.0.17-1~deb12u1)
- libssl3:amd64 (3.0.16-1~deb12u1 -> 3.0.17-1~deb12u1)

# Atualização e limpeza concluídas com sucesso!
# Fim da execução: 06/08/2025 16:31:15
```

---

## 📜 Licença

Este projeto é distribuído sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.