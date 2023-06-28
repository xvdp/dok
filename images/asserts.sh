#!/bin/bash

ASSERT_DIR () {
  if [ ! -d "${1}" ]; then
    echo "FOLDER ${1} not found"
    exit 1
  fi
}

ASSERT_FILE () {
  if [ ! -f "${1}" ]; then
    echo "FILE ${1} not found"
    exit 1
  fi
}