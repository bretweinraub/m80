# -*-sh-*-

#
# generate a sample m4 file
#
echo "m4_include(m4/base.m4)" > test_base.m4.m80
echo "m4_define([XXX],[YYY])" >> test_base.m4.m80
echo "XXX" >> test_base.m4.m80


#
# generate a Makefile that uses local.mk to derive m4 rule
#
echo 'M80LIB = $(shell m80 --libpath)' > Makefile
echo 'include $(M80LIB)/make/local.mk' >> Makefile
echo '%.m4 : %.m4.m80' >> Makefile
echo '	$(M4) $(M4_FLAGS) $< > $@' >> Makefile


#
# create the verification file
#
(cat <<EOF




YYY
EOF
)> check_base.m4

#
# test local.mk
make test_base.m4
res=$?
if test $res -ne 0; then
    echo "failed to confirm \$M80LIB/make/local.mk M4 rule or base.m4"
    exit $res
fi

diff -Bb check_base.m4 test_base.m4
res=$?
if test $res -ne 0; then
    echo "failed to confirm \$M80LIB/make/local.mk M4 rule or base.m4"
    exit $res
fi



#
# test m4conv
rm -f test_base.m4
echo '%.m4 : %.m4.m80' > Makefile
echo '	m4conv $< $@' >> Makefile

make test_base.m4
res=$?
if test $res -ne 0; then
    echo "failed to confirm m4conv or base.m4"
    exit $res
fi

diff -Bb check_base.m4 test_base.m4
res=$?
if test $res -ne 0; then
    echo "failed to confirm m4conv or base.m4"
    exit $res
fi

exit 0


