#!/bin/bash

# --- Definição de Cores ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # Sem Cor

# --- Tratamento de Erros ---
# Função a ser chamada quando um comando falhar
function cleanup_on_error {
  local exit_code=$?
  echo -e "\n${RED}ERRO: O script falhou inesperadamente na linha $1 com código de saída $exit_code.${NC}"
  echo -e "${BLUE}# Fim da execução com erro: $(date '+%d/%m/%Y %H:%M:%S')${NC}"
  exit $exit_code
}
# 'trap' captura o sinal de erro (ERR) e chama a função de limpeza
trap 'cleanup_on_error $LINENO' ERR

# Garante que o script pare imediatamente se qualquer comando falhar
set -e

# --- Processamento de Argumentos ---
interactive_mode=false
if [[ "$1" == "--interactive" ]]; then
  interactive_mode=true
fi

SCRIPT_VERSION="1.2.0"

# --- Início da Execução ---
echo -e "${BLUE}# Atualizador Inteligente v${SCRIPT_VERSION}${NC}"
echo -e "${BLUE}# Desenvolvido por: Paulo Rocha + IA${NC}"
echo -e "${BLUE}# Início da execução: $(date '+%d/%m/%Y %H:%M:%S')${NC}"

# --- Verificações Iniciais ---
# 1. Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Este script precisa ser executado como root ou com 'sudo'.${NC}" >&2
  exit 1
fi

# 2. Verifica se o comando 'apt-get' existe
if ! command -v apt-get &> /dev/null; then
    echo -e "${RED}ERRO: O comando 'apt-get' não foi encontrado. Este script é compatível apenas com sistemas baseados em Debian.${NC}" >&2
    exit 1
fi

# 3. Verifica se há conexão com a internet
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${RED}ERRO: Sem conexão com a internet.${NC}"
    echo -e "${YELLOW}Não é possível continuar. Verifique sua conexão de rede.${NC}"
    exit 1
fi

# --- Lógica Principal ---
echo -e "${BLUE}# Atualizando a lista de pacotes...${NC}"
if ! apt-get update -qq 2>/dev/null; then
    echo -e "${RED}ERRO: Falha ao atualizar a lista de pacotes.${NC}"
    echo -e "${YELLOW}Isso pode ocorrer por problemas de rede ou repositórios configurados incorretamente."
    echo -e "Verifique sua conexão com a internet e o arquivo '/etc/apt/sources.list'."
    echo -e "Em sistemas descontinuados, os repositórios podem estar desativados.${NC}"
    exit 1
fi

echo -e "${BLUE}# Verificando pacotes que podem ser atualizados...${NC}"
upgradable_packages=$(apt list --upgradable 2>/dev/null | tail -n +2)

if [ -z "$upgradable_packages" ]; then
    echo -e "${GREEN}# Seu sistema já está atualizado. Nenhum pacote para atualizar.${NC}"
    echo -e "${BLUE}# Fim da execução: $(date '+%d/%m/%Y %H:%M:%S')${NC}"
    exit 0
fi

echo
echo -e "${YELLOW}# Os seguintes pacotes serão atualizados:${NC}"
echo

# Processa e exibe a lista detalhada de pacotes com versões (agnóstico de idioma)
while read -r line; do
    pkg_name=$(echo "$line" | awk -F'/' '{print $1}')
    new_ver=$(echo "$line" | awk '{print $2}')
    # Versão agnóstica de idioma: procura pelo padrão [*: versão]
    current_ver=$(echo "$line" | awk '{sub(/.*\[.*: /,""); sub(/].*/,""); print}')
    echo -e "- ${pkg_name} ${GREEN}(${current_ver})${NC} ${BLUE}->${NC} ${GREEN}(${new_ver})${NC}"
done <<< "$upgradable_packages"

echo

# --- Confirmação do Usuário (apenas em modo interativo) ---
if [ "$interactive_mode" = true ]; then
    read -p "Deseja continuar com a atualização? (s/N) " -n 1 -r; echo
    if [[ ! $REPLY =~ ^[sS]$ ]]; then
        echo "Atualização cancelada pelo usuário."
        exit 1
    fi
fi

# --- Execução da Atualização ---
echo -e "${GREEN}# Iniciando atualização.${NC}"
echo

# Define o modo de front-end do apt e executa a atualização
if [ "$interactive_mode" = false ]; then
    # Modo automático: sem perguntas, sem output.
    echo -e "${BLUE}# Instalando atualizações... (Isso pode levar alguns minutos)${NC}"
    export DEBIAN_FRONTEND=noninteractive
    apt-get upgrade -y > /dev/null
else
    # Modo interativo: permite perguntas e mostra o output do apt.
    echo -e "${YELLOW}# O modo interativo está ativo. O apt pode solicitar sua confirmação.${NC}"
    apt-get upgrade -y
fi

echo -e "${BLUE}# Removendo pacotes desnecessários...${NC}"
apt-get autoremove -y -qq > /dev/null

echo -e "${BLUE}# Limpando o cache de pacotes...${NC}"
apt-get autoclean -y -qq > /dev/null

echo
echo -e "${YELLOW}----------------------------------------------------${NC}"
echo -e "${YELLOW}# Resumo do que foi efetivamente atualizado:${NC}"
echo -e "${YELLOW}----------------------------------------------------${NC}"

# Usa awk para encontrar o último bloco de 'upgrade' e sed para formatar a saída
last_upgrade_log=$(awk '/^Start-Date/ { record = "" } { record = record $0 ORS } /^End-Date/ { if (record ~ /Commandline: apt-get upgrade -y/) last_upgrade = record } END { printf "%s", last_upgrade }' /var/log/apt/history.log)

upgraded_list=$(echo "$last_upgrade_log" | grep "Upgrade:" | sed 's/Upgrade: //' | sed 's/), /)\n/g' | sed 's/, / -> /' | sed 's/^/- /')

if [ -z "$upgraded_list" ]; then
    echo -e "${GREEN}# Nenhum pacote foi efetivamente atualizado nesta execução.${NC}"
else
    echo -e "${GREEN}$upgraded_list${NC}"
fi

echo
echo -e "${GREEN}# Atualização e limpeza concluídas com sucesso!${NC}"
echo -e "${BLUE}# Fim da execução: $(date '+%d/%m/%Y %H:%M:%S')${NC}"
