#!/bin/bash

if [ "$1" == "--" ]; then
  shift
fi

exec "$@"
