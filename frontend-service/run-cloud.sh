#!/usr/bin/env bash

./mvnw spring-boot:run -Dspring.profiles.active=cloud -Dspring.cloud.gcp.credentials.location=file:///$HOME/google/permanent-make-up/project-editor.json
