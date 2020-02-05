#!/bin/bash

az login
az extension add --name azure-devops

for project in $(az devops project list --org https://dev.azure.com/$ORG/ | jq -r '.value[].id'); do
    for repo in $(az repos list --org https://dev.azure.com/$ORG/ -p $project | jq -r '.[].remoteUrl'); do
        if [ -n "$repo" ] ; then
            git clone $(sed "s/@/:$(az account get-access-token | jq -r '.accessToken')@/" <<< $repo) && cd "$(basename $repo .git)"
			git log --pretty=format:user:%aN%n%at --reverse --raw --encoding=UTF-8 --no-renames | gource --output-custom-log - | sed -r "s#(.+)\|#\1|/$repo#" >> /mnt/gource-azure-repos/commits.log
            cd ../ && rm -fr "$(basename $repo)"
        else
        echo "No repos for project ID: $repo"
        fi
    done
done

sort -n -o /mnt/gource-azure-repos/commits.log mnt/gource-azure-repos/commits.log
