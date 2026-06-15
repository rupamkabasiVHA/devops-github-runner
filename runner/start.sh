#!/bin/bash

./config.sh \
  --url $REPO_URL \
  --token $RUNNER_TOKEN \
  --labels ecs-runner \
  --unattended

./run.sh