#!/bin/bash

set -eu

function update_project {
    export HBPROJECT=$1

    echo "Updating $HBPROJECT"

    pushd template > /dev/null
    for f in $(find . -print)
    do
        if [[ -f "$f" ]]; then
            EXTENSION="${f##*.}"
            if [[ "$EXTENSION" == "sh" ]]; then
                cp "$f" ../../$HBPROJECT/"$f"
            else
                cat "$f" | envsubst > ../../$HBPROJECT/"$f"
            fi
        elif [[ -d "$f" ]]; then
            if [[ ! -d ../../$HBPROJECT/"$f" ]]; then
                mkdir ../../$HBPROJECT/"$f"
            fi
        fi
    done
    popd > /dev/null
}

PROJECT=$1

if [[ -z "$PROJECT" ]]; then

    update_project hummingbird
    update_project hummingbird-auth
    update_project hummingbird-compression
    update_project hummingbird-core
    update_project hummingbird-fluent
    update_project hummingbird-lambda
    update_project hummingbird-mustache
    update_project hummingbird-redis
    update_project hummingbird-websocket

else
    update_project "$PROJECT"
fi
