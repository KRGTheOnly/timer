#!/usr/bin/env bash


if [ "$1" == "run" ]; then
  v run src/ $2
else
  v src -o timer
fi