#!/usr/bin/env bash

set_active_project() {
    gcloud auth login
    gcloud config set project elevated-range-213101
    gcloud auth application-default login
}

set_active_project