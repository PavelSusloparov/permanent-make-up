#!/usr/bin/env bash

set_active_project() {
    gcloud auth login
    gcloud config set project permanent-make-up
    gcloud auth application-default login
}

set_active_project