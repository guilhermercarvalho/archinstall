# Arch Install

Este programa tem como objetivo auxiliar a formatação e instalação do Arch Linux em seu sistema.

Originalmente, desenvolvido com base no meu uso diário este programa foi desenvolvido especificamente para meu uso. Mais adiante pretendo torná-lo mais genérico para que qualquer usuário possa usufruí-lo.

## *Windows*

O *Arch Install* realiza a automatização da formatação e configuração do sistema. Caso você tenha mais familiaridade com sistemas GNU/Linux.

Se você é novo nesse mundo Software Livre, recomendo optar por distribuições mais completas como [Ubuntu](https://ubuntu.com/), [Mint](https://linuxmint.com/) ou [Manjaro](https://manjaro.org/)

Manjaro é uma distribuição que utiliza o Arch como base para o sistema, portanto, é interessante para se ambientar com as especificidades da distribuição.

## *Linux*

Se você está familiarizado com sistemas GNU/Linux e deseja se aventurar com o Arch este script é um auxiliador. Porém, se é sua primeira vez, recomendo ler atentamente o [Guia de Instalação Official](https://wiki.archlinux.org/index.php/Installation_guide) da comunidade e instalar manualmente o sistema. O Arch Linux possui uma comunidade apaixonada e uma [Wiki](https://wiki.archlinux.org/) rica em detalhes. Você dificilmente ficará sem solução para qualquer eventual problema. :wink:

### Download e BOOT da ISO

Primeiramente você precisa fazer o download da ISO mais recente do sistema e bootar a ISO em um pendrive.

#### Manual

* Realizar download da ISO em [Arch Linux Downloads](https://www.archlinux.org/download/).
* Bootar ISO em um pendrive utilizando algum programa como [Etcher](https://www.balena.io/etcher/), [GNOME Disks](https://wiki.gnome.org/Apps/Disks) ou o comando [dd](http://man7.org/linux/man-pages/man1/dd.1.html).
* Reiniciar a máquina com pendrive como dispositivo primário de boot do sistema.

#### Automático

Pensando na facilitação deste processo também criei o programa *install_iso_arch* que realiza todos estes processos em qualquer sistema Unix.

## Configurando ambiente

Após o início da ISO será aberta uma sessão do terminal. Será necessário a execução de alguns comandos para realizar o download deste programa.

```bash
loadkeys i386/qwerty/br-abnt2.map.gz
```

```bash
yes n | pacamn -Syyuu
```

```bash
pacman -S git --noconfirm
```

```bash
git clone https://github.com/guilhermercarvalho/archinstall.git
```

### Iniciando instalação

```bash
sh archinstall/pre_install_arch.sh
```

Siga os passos listados durante a execução do programa.
