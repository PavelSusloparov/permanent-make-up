#!/usr/bin/env bash

./mvnw clean package jib:build -Dspring.profiles.active=secure
