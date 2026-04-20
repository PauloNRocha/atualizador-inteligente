# Atualizador Inteligente para Debian/Ubuntu

![Versão](https://img.shields.io/badge/version-v1.3.0-blue.svg)
![Licença](https://img.shields.io/badge/license-MIT-green.svg)

Script em shell para atualização de sistemas Debian e Ubuntu com foco em execução automática, previsibilidade operacional e comportamento compatível com servidores.

## Visão Geral

O script executa o fluxo `apt-get update`, `apt-get upgrade`, `apt-get autoremove` e `apt-get autoclean` em sequência.

Ele foi pensado para uso recorrente em servidor, com duas prioridades:

- reduzir falhas causadas por validações artificiais de conectividade;
- manter o comportamento previsível do `apt-get upgrade`, sem migrar para `dist-upgrade` ou `full-upgrade`.

O que o script faz:

- valida execução como `root`;
- confirma a presença do `apt-get`;
- tenta atualizar os índices reais do APT;
- gera uma prévia dos pacotes pendentes com `apt-get -s upgrade`;
- executa a atualização;
- remove pacotes obsoletos e limpa o cache;
- exibe um resumo final com base no histórico do APT.

O que o script não faz:

- não executa `dist-upgrade`;
- não altera repositórios;
- não gerencia reinicialização do sistema;
- não instala automaticamente pacotes novos exigidos por mudanças mais complexas de dependência.

## Modos de Execução

### Modo automático

Indicado para `systemd timer`, `cron` ou execução manual sem interação.

```bash
sudo ./atualizar-sistema.sh
```

Nesse modo, o script exporta `DEBIAN_FRONTEND=noninteractive` e executa `apt-get upgrade -y`.

Quando a execução acontece em um terminal interativo, o script exibe um indicador visual simples durante a etapa de upgrade para deixar claro que o processo continua em andamento.

Quando a execução acontece por `systemd timer` ou `cron`, esse indicador não é exibido, evitando ruído desnecessário em logs.

### Modo interativo

Indicado para revisão manual antes da atualização.

```bash
sudo ./atualizar-sistema.sh --interactive
```

Nesse modo, o script:

- lista os pacotes identificados na simulação;
- pede uma confirmação inicial;
- executa `apt-get upgrade` sem `-y`, permitindo interação real com o APT.

### Ajuda

```bash
./atualizar-sistema.sh --help
```

## Requisitos

- sistema baseado em Debian ou Ubuntu;
- `bash`;
- `apt-get`;
- privilégios administrativos.

## Agendamento Recomendado com systemd timer

Para ambiente de produção, `systemd timer` é o agendamento recomendado. Ele oferece integração melhor com `systemctl`, `journalctl` e estado de execução do serviço.

### 1. Tornar o script executável

```bash
chmod +x atualizar-sistema.sh
```

### 2. Criar a unit de serviço

Crie o arquivo `/etc/systemd/system/atualizador-inteligente.service`:

```ini
[Unit]
Description=Atualizador Inteligente para Debian/Ubuntu
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/caminho/completo/para/atualizar-sistema.sh
```

Substitua `/caminho/completo/para/atualizar-sistema.sh` pelo caminho real do script no servidor.

### 3. Criar o timer

Crie o arquivo `/etc/systemd/system/atualizador-inteligente.timer`:

```ini
[Unit]
Description=Executa o Atualizador Inteligente semanalmente

[Timer]
OnCalendar=Mon *-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

O exemplo acima agenda a execução para toda segunda-feira, às 03:00.

### 4. Recarregar o systemd e habilitar o timer

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now atualizador-inteligente.timer
```

### 5. Verificar o agendamento

```bash
sudo systemctl list-timers atualizador-inteligente.timer
sudo systemctl status atualizador-inteligente.service
```

### 6. Consultar logs

```bash
sudo journalctl -u atualizador-inteligente.service
```

## Agendamento com cron

`cron` continua sendo uma opção válida quando o ambiente já depende desse modelo.

Edite o `crontab` do `root`:

```bash
sudo crontab -e
```

Adicione uma entrada com caminho absoluto:

```cron
0 3 * * 1 /caminho/completo/para/atualizar-sistema.sh >> /var/log/atualizacoes-sistema.log 2>&1
```

Esse exemplo executa o script toda segunda-feira às 03:00 e grava a saída em `/var/log/atualizacoes-sistema.log`.

## Exemplo de Saída

```bash
# Atualizador Inteligente v1.3.0
# Desenvolvido por: Paulo Rocha + IA
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

## Licença

Este projeto é distribuído sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
