#!/bin/bash

USER=$(whoami)

pyversion=$1
kernel_name=$2

pversion=$(pyenv versions --bare | grep '^${pyversion}$')
virtualenv=$(pyenv virtualenvs --bare | grep '^${kernel_name}$')
kernel_path="/Users/${USER}/Library/Jupyter/kernels/${kernel_name}"

GRN='\033[0;32m'
RED='\033[0;31m'
YLW='\033[1;33m'
NC='\033[0m' # No Color

# Install python version 
if [ ! -z $pversion ]
then
	echo -e "${YLW}Installing python ${pyversion}..${NC}"
  env \
    PATH="$(brew --prefix tcl-tk)/bin:$PATH" \
    LDFLAGS="-L$(brew --prefix tcl-tk)/lib" \
    CPPFLAGS="-I$(brew --prefix tcl-tk)/include" \
    PKG_CONFIG_PATH="$(brew --prefix tcl-tk)/lib/pkgconfig" \
    CFLAGS="-I$(brew --prefix tcl-tk)/include" \
    PYTHON_CONFIGURE_OPTS="--with-tcltk-includes='-I$(brew --prefix tcl-tk)/include' --with-tcltk-libs='-L$(brew --prefix tcl-tk)/lib -ltcl8.6 -ltk8.6'" \
    pyenv install $pyversion
else
	echo -e "${GRN}${pyversion} already installed !${NC}"
fi

# Install virtualenv
if [  -z $virtualenv ]
then
  echo -e "${YLW}Creating virtualenv ${kernel_name}..${NC}"
  pyenv virtualenv $pyversion $kernel_name
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  pyenv activate $kernel_name
  if [ $? -eq 0 ]
  then
    # Install dependencies
    echo -e "${YLW}Installing dependecies..${NC}"
    pip install -r requirements.txt
    
    # Kernel config
    if [ ! -d $kernel_path ]
    then
    	echo -e "${YLW}Configuring kernel: ${kernel_name}${NC}"
    	mkdir $kernel_path
    fi
    	sed s/KERNELNAME/$kernel_name/g kernel.json > /Users/${USER}/Library/Jupyter/kernels/$kernel_name/kernel.json
  else
  	echo -e "${RED}Env activation problem !${NC}"
  fi 
else
	echo -e "${GRN}${kernel_name} already exists !${NC}"
fi