#!/bin/bash
##===----------------------------------------------------------------------===##
##
## This source file is part of the Swift Distributed Actors open source project
##
## Copyright (c) 2018-2019 Apple Inc. and the Swift Distributed Actors project authors
## Licensed under Apache License v2.0
##
## See LICENSE.txt for license information
## See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
##
## SPDX-License-Identifier: Apache-2.0
##
##===----------------------------------------------------------------------===##

set -e

echo "WARNING: This operation will clear any work on the current branch!"

my_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
root_path="$my_path/../.."
version=$(git describe --abbrev=0 --tags || echo "snapshot")

git clean -fdx

echo "Generating api docs ==========================="
$my_path/generate_api.sh

echo "Generating reference docs (html) =============="
$my_path/generate_reference.sh

echo "Generating reference docs (pdf) ==============="
$my_path/generate_reference_pdf.sh

echo "Moving changes to [gh-pages] =================="
declare -r tmp="/tmp/swift-distributed-actors-docs"
rm -rf "$tmp"
mkdir "$tmp"

cp -R "$root_path/.build/docs/api" "$tmp/"
cp -R "$root_path/.build/docs/reference" "$tmp/"

echo $tmp
echo "FIXME"
exit 0

git checkout gh-pages

cp -R /tmp/swift-distributed-actors-docs/api/* api/
cp -R /tmp/swift-distributed-actors-docs/reference/* reference/

echo "Done copying docs to [gh-pages]..."

git add api
git add reference
git commit -m "Docs [${version}] updated ${date}"

echo "Done; Please remember to push:"
echo "    git push origin gh-pages"