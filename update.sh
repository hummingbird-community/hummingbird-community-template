#!/bin/bash

# Install mustache with `gem install mustache`

set -eu

function run_mustache {
    SRC=$1
    DEST=$2
    PROJECT=$3
    TEMPLATE_CONTEXT=$4

    echo "project: $PROJECT" | cat - $TEMPLATE_CONTEXT | mustache - "$SRC" > "$DEST"
}

function update_project {
    export PROJECT_PATH=$1
    export PROJECT_NAME=$(basename $1)

    echo "Updating $PROJECT_NAME"

    export OPTIONAL_TEMPLATE_CONTEXT="$PROJECT_PATH/.hummingbird-community-template.yml"
    if [[ -f "$OPTIONAL_TEMPLATE_CONTEXT" ]]; then
        TEMPLATE_CONTEXT="$OPTIONAL_TEMPLATE_CONTEXT"
    else
        TEMPLATE_CONTEXT="../default.yml"
    fi

    pushd template > /dev/null
    for f in $(find . -print)
    do
        if [[ -f "$f" ]]; then
            EXTENSION="${f##*.}"
            if [[ "$EXTENSION" == "sh" ]]; then
                cp "$f" "$PROJECT_PATH"/"$f"
            elif [[ "$EXTENSION" == "mustache" ]]; then
                run_mustache "$f" "$PROJECT_PATH"/"${f%.*}" "$PROJECT_NAME" "$TEMPLATE_CONTEXT"
            else
                cp "$f" "$PROJECT_PATH"/"$f"
                #cat "$f" | envsubst > ../../$HBPROJECT/"$f"
            fi
        elif [[ -d "$f" ]]; then
            if [[ ! -d "$PROJECT_PATH"/"$f" ]]; then
                mkdir "$PROJECT_PATH"/"$f"
            fi
        fi
    done
    popd > /dev/null
}

PROJECT_PATH=${1-}
if [[ -z "$PROJECT_PATH" ]]; then
    echo "Usage: update.sh <path to project>"
else
    FULL_PROJECT_PATH=$(cd "$(dirname "$PROJECT_PATH")"; pwd -P)/$(basename "$PROJECT_PATH")
    update_project "$FULL_PROJECT_PATH"
fi
