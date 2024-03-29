#!/bin/bash
if [[ -d public ]]; then
    GLOBIGNORE=*.git
    rm -rf -v public/*
fi
hugo
if [[ -n "$1" ]]; then
    cd public
    git add -A
    git commit -m "$1"
    git push
else
    echo
    echo "[WARN] Files will NOT be uploaded to Github without adding comments."
    echo "Usage: $(basename "$0") COMMIT_COMMENTS"
fi