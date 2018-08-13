#!/usr/bin/env bash

./mvnw spring-boot:run -Dserver.port=8081 -Dspring.profiles.active=cloud -Dspring.cloud.gcp.credentials.location=file:///$HOME/google/permanent-make-up/project-editor.json
