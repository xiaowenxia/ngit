#!/bin/sh

test_description='git ls-files --format test'

TEST_PASSES_SANITIZE_LEAK=true
. ./test-lib.sh

for flag in -s -o -k -t --resolve-undo --deduplicate --eol
do
	test_expect_success "usage: --format is incompatible with $flag" '
		test_expect_code 129 git ls-files --format="%(objectname)" $flag
	'
done

test_expect_success 'setup' '
	printf "LINEONE\nLINETWO\nLINETHREE\n" >o1.txt &&
	printf "LINEONE\r\nLINETWO\r\nLINETHREE\r\n" >o2.txt &&
	printf "LINEONE\r\nLINETWO\nLINETHREE\n" >o3.txt &&
	ln -s o3.txt o4.txt &&
	git add "*.txt" &&
	git add --chmod +x o1.txt &&
	git update-index --add --cacheinfo 160000 $(git hash-object o1.txt) o5.txt &&
	git commit -m base
'

test_expect_success 'git ls-files --format objectmode v.s. -s' '
	git ls-files -s | awk "{print \$1}" >expect &&
	git ls-files --format="%(objectmode)" >actual &&
	test_cmp expect actual
'

test_expect_success 'git ls-files --format objectname v.s. -s' '
	git ls-files -s | awk "{print \$2}" >expect &&
	git ls-files --format="%(objectname)" >actual &&
	test_cmp expect actual
'

test_expect_success 'git ls-files --format v.s. --eol' '
	git ls-files --eol >tmp &&
	sed -e "s/	/ /g" -e "s/  */ /g" tmp >expect 2>err &&
	test_must_be_empty err &&
	git ls-files --format="i/%(eolinfo:index) w/%(eolinfo:worktree) attr/%(eolattr) %(path)" >actual 2>err &&
	test_must_be_empty err &&
	test_cmp expect actual
'

test_expect_success 'git ls-files --format path v.s. -s' '
	git ls-files -s | awk "{print \$4}" >expect &&
	git ls-files --format="%(path)" >actual &&
	test_cmp expect actual
'

test_expect_success 'git ls-files --format with -m' '
	echo change >o1.txt &&
	cat >expect <<-\EOF &&
	o1.txt
	o5.txt
	EOF
	git ls-files --format="%(path)" -m >actual &&
	test_cmp expect actual
'

test_expect_success 'git ls-files --format with -d' '
	echo o6 >o6.txt &&
	git add o6.txt &&
	rm o6.txt &&
	cat >expect <<-\EOF &&
	o5.txt
	o6.txt
	EOF
	git ls-files --format="%(path)" -d >actual &&
	test_cmp expect actual
'

test_expect_success 'git ls-files --format imitate --stage' '
	git ls-files --stage >expect &&
	git ls-files --format="%(objectmode) %(objectname) %(stage)%x09%(path)" >actual &&
	test_cmp expect actual
'

test_expect_success 'git ls-files --format with --debug' '
	git ls-files --debug >expect &&
	git ls-files --format="%(path)" --debug >actual &&
	test_cmp expect actual
'

test_done
