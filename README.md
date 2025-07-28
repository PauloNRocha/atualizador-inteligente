# Script de Atualização de Pacotes no Debian/Ubuntu

## 📌 Objetivo

Este script realiza uma atualização completa e segura do sistema. Foi projetado para ser robusto, com uma saída visualmente clara e colorida.

**Principais Características:**
1.  **Compatibilidade de Idioma**: Funciona em sistemas Debian/Ubuntu configurados em qualquer idioma (inglês, português, etc.).
2.  **Robusto e Seguro**: Possui tratamento de erros que interrompe a execução em caso de falha e verifica se o sistema é compatível.
3.  **Saída Detalhada**: Exibe a lista de pacotes a serem atualizados, mostrando a transição de `versão_antiga -> versão_nova`.
4.  **Modo Duplo**: Executa automaticamente por padrão (ideal para `cron`) e oferece um modo interativo (`--interactive`) para revisão manual.
5.  **Relatório Final**: Apresenta um resumo claro dos pacotes que foram efetivamente atualizados.

---

## 🧰 Requisitos

-   Distribuição baseada em Debian (Debian, Ubuntu, etc.).
-   Acesso `root` (ou uso de `sudo`).
-   Um terminal que suporte cores ANSI.

---

## 📂 Como Usar

### 1. Dê permissão de execução

Se ainda não o fez, torne o script executável:

```bash
chmod +x /caminho_para_script/atualizar-sistema.sh
```

### 2. Execução Automática (Padrão)

Para rodar o script de forma direta, sem interrupções. Este é o modo ideal para agendamentos `cron` e outras automações.

```bash
sudo ./atualizar-sistema.sh
```

### 3. Execução Interativa

Para revisar os pacotes e confirmar a atualização manualmente, use a flag `--interactive`:

```bash
sudo ./atualizar-sistema.sh --interactive
```
O script irá listar os pacotes e aguardar sua confirmação antes de prosseguir.

---

## ⏰ Como Agendar no `cron`

Para agendar a execução automática (por exemplo, toda segunda-feira às 3h da manhã), edite o `crontab` do root:

```bash
sudo crontab -e
```

Adicione a seguinte linha. **Não é necessário usar nenhuma flag**, pois o modo automático é o padrão.

```cron
0 3 * * 1 /caminho/completo/para/atualizar-sistema.sh >> /var/log/atualizacoes-sistema.log 2>&1
```
---

## 🧪 Exemplo de Saída

A saída do script utiliza cores para facilitar a leitura:
-   **Azul**: Informações de execução e o símbolo `>`.
-   **Amarelo**: Títulos.
-   **Verde**: Mensagens de sucesso, versões e o resumo final.
-   **Vermelho**: Mensagens de erro.

```bash
# Início da execução: 27/07/2025 18:00:00
# Atualizando a lista de pacotes...
# Verificando pacotes que podem ser atualizados...

# Os seguintes pacotes serão atualizados:

- sudo (1.9.13p3-1+deb12u1) -> (1.9.13p3-1+deb12u2)
- ca-certificates (20230311) -> (20230311+deb12u1)

# Iniciando atualização.

# Instalando atualizações... (Isso pode levar alguns minutos)
# Removendo pacotes desnecessários...
# Limpando o cache de pacotes...

----------------------------------------------------
# Resumo do que foi efetivamente atualizado:
----------------------------------------------------
- sudo (1.9.13p3-1+deb12u1 -> 1.9.13p3-1+deb12u2)
- ca-certificates (20230311 -> 20230311+deb12u1)

# Atualização e limpeza concluídas com sucesso!
# Script desenvolvido por Paulo Rocha
# Fim da execução: 27/07/2025 18:01:15
```
