#!/bin/zsh
echo -n enter target:
read target
aws ssm start-session --target $target --document-name SSMSessionManagerRunShell