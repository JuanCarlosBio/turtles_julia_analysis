## SO a utilizar
FROM ubuntu:24.04

## Establecer variables de ambiente
ENV DEBIAN_FRONTEND=noninteractive

## Instalar dependencias
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    vim \
    tmux \
    python3-pip \
    build-essential \
    software-properties-common \
    dirmngr \
    gnupg

## Instalar Firefox
RUN apt-get update && \
    apt-get install -y firefox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## Instalar R desde el repositorio oficial
RUN apt-get update && \
    apt-get install -y \
    r-base \
    r-cran-tidyverse \
    r-cran-sf \
    r-cran-glue \
    r-cran-rstatix \
    r-cran-ggtext

## Descargar e instalar Julia
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.0-linux-x86_64.tar.gz && \
    tar -xvzf julia-1.10.0-linux-x86_64.tar.gz && \
    mv julia-1.10.0 /opt/julia && \
    ln -s /opt/julia/bin/julia /usr/local/bin/julia && \
    rm julia-1.10.0-linux-x86_64.tar.gz

## Verificar la instalación de Julia
RUN julia --version

## Instalar paquetes de Python3
RUN apt-get install -y \
    python3-pandas \
    python3-geopandas \
    python3-matplotlib 

## Copiar archivos de la aplicación
COPY ./ /app

## Instalar paquetes de Julia
RUN julia /app/code/packages/packages.jl

## Limpiar caché de apt para reducir el tamaño de la imagen
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## Comando predeterminado
CMD ["/bin/bash"]
