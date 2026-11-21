#!/bin/sh
grep -rl "package:http" lib/ | grep -v -e core/api -e _repository.dart
grep -rl "package:flutter/material" lib/ | grep -e _model.dart -e _repository.dart -e core/api
exit 0
