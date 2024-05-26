#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]; then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  sudo apt-get update
  sudo apt-get install --yes unzip

  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $RALPM_TMP_DIR/cpython-3.9.13.tar.gz
  tar xf $RALPM_TMP_DIR/cpython-3.9.13.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/cpython-3.9.13.tar.gz

  $RALPM_PKG_INSTALL_DIR/python/bin/pip3.9 install virtualenv

  wget https://github.com/Telefonica/HomePWN/archive/080398174159f856f4155dcb155c6754d1f85ad8.zip -O $RALPM_TMP_DIR/homepwn.zip
  unzip $RALPM_TMP_DIR/homepwn.zip -d $RALPM_PKG_INSTALL_DIR
  mv $RALPM_PKG_INSTALL_DIR/HomePWN-080398174159f856f4155dcb155c6754d1f85ad8 $RALPM_PKG_INSTALL_DIR/homepwn
  cd $RALPM_PKG_INSTALL_DIR/homepwn
  sudo ./install.sh

  sudo ln -s $RALPM_PKG_INSTALL_DIR/homepwn/homePwn.py /usr/bin/homepwn
  sudo chmod +x /usr/bin/homepwn
}

uninstall() {
  sudo rm -rf $RALPM_PKG_INSTALL_DIR/python
  sudo rm -rf $RALPM_PKG_INSTALL_DIR/homepwn
  sudo rm /usr/bin/homepwn
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1
