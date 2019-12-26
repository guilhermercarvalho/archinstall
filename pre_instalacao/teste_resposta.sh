#!/usr/bin/env bash

red_full=$'\e[1;31m%s\e[0m\n'
grn_full=$'\e[1;32m%s\e[0m\n'
yel_full=$'\e[1;33m%s\e[0m\n'
blu_full=$'\e[1;34m%s\e[0m\n'
mag_full=$'\e[1;35m%s\e[0m\n'
cyn_full=$'\e[1;36m%s\e[0m\n'

red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

ler_resposta() {
    if [[ $resposta =~ ^[sS]([iI][mM])*$ || $resposta = "" ]]; then
        return 0
    else
        return -1
    fi
}

read -p "Correto?[S/n] " resposta
ler_resposta
if [ $? -eq 0 ]; then
    printf "$cyn_full" "Sim"
    echo "# UEFI indisponível, usando LEGACY #"
    printf "%s\n" "# UEFI "${red}"indisponível${end}, usando ${red}LEGACY${end} #"
    printf "%s\n" "Text in ${red}red${end}, white and ${blu}blue${end}."
else
    echo "Nao"
fi

if [ -d /sys/firmware/efi/efivars ]; then
    echo "###################"
    printf "%s\n" "# ${blu}UEFI${end} ${grn}disponível${end} #"
    echo "###################"

    BOOT_UFEI=1
else
    echo "####################################"
    printf "%s\n" "# ${blu}UEFI${end} ${red}indisponível${end}, usando ${yel}LEGACY${end} #"
    echo "####################################"

    BOOT_LEGACY=1
fi
fim_msg