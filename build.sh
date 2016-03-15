while getopts 'acshj:' flag; do
	case "${flag}" in
                h)
                        echo "Build script for Yun/Yun101/Yun Shield Openwrt"
                        echo " "
                        echo "options:"
                        echo "-h,			show brief help"
                        echo "-a,			compile all packages"
                        echo "-c,			clean before building"
                        echo "-s,			safe mode, single job and verbose output"
                        exit 0
                        ;;
                a)
                        export COMPILEALL=1
			;;
                s)	
			export JOBS=1
			export EXTRAFLAGS="V=s"
			;;
                c)
			export CLEAN=1
                        ;;
		*)	
			export COMPILEALL=0
			export CLEAN=0
			export JOBS=`ls -d /sys/devices/system/cpu/cpu[[:digit:]]* | wc -w `
			;;
        esac
done

echo $CLEAN
echo $JOBS $EXTRAFLAGS
exit 1

if [ x$CLEAN == x1 ]; then
make clean
./scripts/feeds uninstall -a
./scripts/feeds update -a
./scripts/feeds install -a -d m

./scripts/feeds uninstall  libfreecwmp libmicroxml sslh libesmtp luajit tracertools pcre linknx vala

rm -rf ./package/feeds/packages/rng-tools
rm -rf ./package/feeds/packages/avrdude
ln -s ../../../feeds/arduino/rng-tools ./package/feeds/arduino/rng-tools
ln -s ../../../feeds/arduino/avrdude ./package/feeds/arduino/avrdude
fi

if [ x$COMPILEALL == x1 ]; then
cp config.full .config
else
cp config.default .config
fi

make oldconfig

make IGNORE_ERRORS=m $EXTRAFLAGS -j$JOBS

