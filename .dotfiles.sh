#!/bin/bash

SCRIPT_DIR_PATH="$(dirname "$(realpath "$0")")"

dotfiles_help() {
  echo "- - - -  -"
  echo -e "Script usage:\t/bin/bash ${0} macos/linux"
  echo
  echo -e "Script Dir:\t${SCRIPT_DIR_PATH}"
  echo -e "Script Name:\t${0}"
}

if [ "${#}" == 1 ]; then
  if [ "${1}" == "macos" ]; then
    python3 ${SCRIPT_DIR_PATH}/.dotfiles/init.py "${1}"
  elif [ "${1}" == "macos" ]; then
    python3 ${SCRIPT_DIR_PATH}/.dotfiles/init.py "${1}"
  else
    dotfiles_help
  fi
else
  dotfiles_help
fi
