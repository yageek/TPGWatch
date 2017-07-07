#!/bin/sh

#  publish-doc.sh
#  TPGSwift
#
#  Created by Yannick Heinrich on 14.06.16.
#  Copyright © 2016 yageek. All rights reserved.

if [ "$TRAVIS_BRANCH" != "master" ]; then
    echo "Not master skip."
fi

REPO_NAME="TPGSwift"

if [ "$TRAVIS_REPO_SLUG" == "yageek/${REPO_NAME}" ]; then

echo "Generating docs..."
bundle exec jazzy --clean --author "Yannick Heinrich" --author_url "http://blog.yageek.net" --github_url "https://github.com/yageek/${REPO_NAME}" --module "${REPO_NAME}" --xcodebuild-arguments "-scheme,${REPO_NAME}" --output "$HOME/docs/swift_output"

if [ $? -ne 0 ]

then
echo "Failed to generate documentation";
exit 1;

fi

echo "Publishing to Github..."

cd $HOME
git config --global user.email "travis@travis-ci.org"
git config --global user.name "travis-ci"
git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/yageek/${REPO_NAME} gh-pages > /dev/null

cd gh-pages
git rm -rf .
cp -Rf $HOME/docs/swift_output/* .
git add -f .
git commit -m "Latest ${REPO_NAME} doc on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"
git push -fq origin gh-pages > /dev/null

if [ $? -ne 0 ]
then
echo "Failed to push documentation. Aborting..."
exit 1
fi

echo "Published ${REPO_NAME} to gh-pages.\n"
fi

