#!/bin/bash

function replace_json_field {
    tmpfile=/tmp/tmp.json
    cp $1 $tmpfile
    jq "$2 |= \"$3\"" $tmpfile > $1
    rm "$tmpfile"
}

# Check if SUFFIX envvar exists
if [[ -z "558289" ]]; then
    echo "Please set the MCW_SUFFIX environment variable to a unique three character string."
    exit 1
fi

if [[ -z "patsza" ]]; then
    echo "Please set the MCW_GITHUB_USERNAME environment variable to your Github Username"
    exit 1
fi

if [[ -z "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" ]]; then
    echo "Please set the MCW_GITHUB_TOKEN environment variable to your Github Token"
    exit 1
fi

if [[ -z "${MCW_GITHUB_URL}" ]]; then
    MCW_GITHUB_URL=https://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@github.com/patsza/Fabmedical.git
fi

git config --global user.email "patryk.szachagluchowicz@dynamicdog.se"
git config --global user.name "patsza"

cp -R ~/MCW-Cloud-native-applications/Hands-on\ lab/lab-files/developer ~/Fabmedical
cd ~/Fabmedical
git init
git remote add origin https://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@github.com/patsza/Fabmedical.git

git config --global --unset credential.helper
git config --global credential.helper store

# Configuring github workflows
cd ~/Fabmedical
sed -i "s/\[SUFFIX\]/558289/g" ~/Fabmedical/.github/workflows/content-init.yml
sed -i "s/\[SUFFIX\]/558289/g" ~/Fabmedical/.github/workflows/content-api.yml
sed -i "s/\[SUFFIX\]/558289/g" ~/Fabmedical/.github/workflows/content-web.yml

# Commit changes
git add .
git commit -m "Initial Commit"

# Get ACR credentials and add them as secrets to Github
ACR_CREDENTIALS=$(az acr credential show -n fabmedical558289)
ACR_USERNAME=$(jq -r -n '$input.username' --argjson input "$ACR_CREDENTIALS")
ACR_PASSWORD=$(jq -r -n '$input.passwords[0].value' --argjson input "$ACR_CREDENTIALS")

GITHUB_TOKEN=$MCW_GITHUB_TOKEN
cd ~/Fabmedical
echo $GITHUB_TOKEN | gh auth login --with-token
gh secret set ACR_USERNAME -b "$ACR_USERNAME"
gh secret set ACR_PASSWORD -b "$ACR_PASSWORD"

# Committing repository
cd ~/Fabmedical
git branch -m master main
git push -u origin main
