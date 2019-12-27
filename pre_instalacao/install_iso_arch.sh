#!/usr/bin/env bash
#
# install_iso.sh - Download e BOOT da ISO mais recente do Arch Linux
#
# Site  : https://github.com/guilhermercarvalho/archinstall
# Autor : Guilherme Carvalho <guilhermercarvalho512@gmail.com>
#
# -------------------------------------------------------------------------------------
#
# Realiza Download e BOOT da ISO mais recente do Arch em um pendrive
#
# -------------------------------------------------------------------------------------
#
# Histórico:
#
#   v1.0 2019-10-21, Guilherme Carvalho:
#       - Versão inicial do programa
#
#
# Licença: -
#
#
#######################################################################################
#
#                                     Menssagem
#                                     ---------
#
echo
echo '-------------------------------------------------------------------------------'
echo '    ____           __        ____   _________ ____     ___              __  '
echo '   /  _/___  _____/ /_____ _/ / /  /  _/ ___// __ \   /   |  __________/ /_ '
echo '   / // __ \/ ___/ __/ __ `/ / /   / / \__ \/ / / /  / /| | / ___/ ___/ __ \'
echo ' _/ // / / (__  ) /_/ /_/ / / /  _/ / ___/ / /_/ /  / ___ |/ /  / /__/ / / /'
echo '/___/_/ /_/____/\__/\__,_/_/_/  /___//____/\____/  /_/  |_/_/   \___/_/ /_/ '
echo '                 Por Guilherme Carvalho - https://github.com/guilhermercarvalho'
echo '-------------------------------------------------------------------------------'
echo
# 
# 
#######################################################################################
#
#                                        Menu
#                                        ----
#   
echo "Qual das etapas deseja realizar?"
echo -e "1)Baixar ISO\n2)Bootar ISO em um pendrive\n3)Iniciar Boot pelo pendrive"

read -p "Etapa(s): " opcao

for i in $opcao
do
    case $i in
        1)  echo "### Etapa 1 ###"
            echo "A ISO mais recente está sendo baixada. Aguarde!"            
            # Encontra ISO mais recente no repositório mantido pela UFPR
            l=$(curl -s http://archlinux.c3sl.ufpr.br/iso/latest/ |
            grep -Eo '\"archlinux-20..\..([1-9]|[10-12])\..([1-9]|[10-31])-x86_64.iso\"' |
            cut -d\" -f2)               
            wget -c -O ${HOME}/archlinux-x86_64.iso http://archlinux.c3sl.ufpr.br/iso/latest/"${l}"
            ;;
        2)  echo "### Etapa 2 ###"
            echo "Este processo irá apagar por completo seu dispositivo."
            echo "Certifique-se de que o dispositivo CORRETO está selecionado!"
            sudo fdisk -l
            echo
            echo "Selecione o dispositivo /dev/sdx. Apenas a letra."
            read dispositivo
            if [[ $dispositivo =~ [a-z] ]]; then
                echo "Dispositivo selecionado: /dev/sd"$dispositivo""
                echo
                read -p "Dispositivo correto?[S/n] " resposta
                if [[ $resposta =~ ^[Nn]([aA][oO])*$ ]]; then
                    echo "Programa Finalizado"
                    exit 1
                fi
            else
                echo "Dispositivo Inválido"
                exit 1
            fi
            echo "Iniciando processo de boot pelo pendrive"
            echo
            dd if=archlinux-x86_64.iso of=/dev/sd"$dispositivo" status="progress"
            echo
            echo "Processo de boot finalizado!"
            echo "Reinicie sua máquina dando boot pelo pendrive."
            exit 0
            ;;
        3)  echo "### Etapa 3 ###"
            echo "Após realizado o download e o BOOT da ISO,"
            echo "inicialize sua máquina com o pendrive como dispositivo primário de BOOT."
            echo "Reinicie a máquina"
            exit 0
            ;;
        *)  echo "### Etapa inválida ###"
        ;;
    esac            
done