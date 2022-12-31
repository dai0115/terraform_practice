#!/bin/zsh
echo -n enter taskID:
read taskid
aws ecs execute-command \
    --cluster ecs_example \
    --task $taskid \
    --container container_definition \
    --interactive \
    --command "/bin/sh"