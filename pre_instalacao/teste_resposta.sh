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


continuar=0
while [ ${continuar} -eq 0 ]; do
    read -p "Continuar?[0/1]" resposta
    if [ ${resposta} -eq 0 ]; then
        continue
    else
        echo "continuar=1"
        continuar=1
    fi
done

