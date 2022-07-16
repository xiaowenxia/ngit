#!/bin/sh

test_description="Test that merge state is as expected after failed merge"

GIT_TEST_DEFAULT_INITIAL_BRANCH_NAME=main
export GIT_TEST_DEFAULT_INITIAL_BRANCH_NAME
. ./test-lib.sh

test_expect_success 'set up custom strategy' '
	test_commit --no-tag "Initial" base base &&
git show-ref &&

	for b in branch1 branch2 branch3
	do
		git checkout -b $b main &&
		test_commit --no-tag "Change on $b" base $b
	done &&

	git checkout branch1 &&
	test_must_fail git merge branch2 branch3 &&
	git diff --exit-code --name-status &&
	test_path_is_missing .git/MERGE_HEAD
'

test_done
