#!/usr/bin/env bash

./cloud_sql_proxy -instances=elevated-range-213101:us-central1:permanent-make-up=tcp:3306 -credential_file=/Users/903940/google/elevated-range-213101/permanent-make-up-cloud-sql-client.json &
