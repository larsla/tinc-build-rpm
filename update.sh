#!/bin/bash

if [ ! $1 ]; then
	echo "Usage: $0 <version>"
	exit -1
fi

VERSION=$1
FILENAME=tinc-${VERSION}.tar.gz

HOME="$(dirname $(readlink -m update.sh))"
BUILDROOT="${HOME}/tmp/build"

if [ ! -d .iterations ]; then
	mkdir .iterations
fi
if [ -f .iterations/${VERSION} ]; then
	ITER=`echo $(cat .iterations/${VERSION}) +1 |bc`
else
	ITER=1
fi
echo $ITER >.iterations/${VERSION}

if [ ! -f "tmp/${FILENAME}" ]; then
	wget -O tmp/${FILENAME} http://tinc-vpn.org/packages/${FILENAME}
	if [ $? -gt 0 ]; then
		echo "ERROR: Couldn't download package"
		exit -1
	fi
else
	touch tmp/${FILENAME}
fi

cp -R build tmp/

cd tmp
tar -zxvf ${FILENAME}
cd tinc-${VERSION}
./configure --prefix=/usr
make
make install DESTDIR=${BUILDROOT}
cd ..
rm -Rf tinc-${VERSION}

cd $HOME

rm -Rf tmp/build/usr/share/info/dir

# build the package
fpm -s dir -t rpm -n tinc -v ${VERSION} -a x86_64 --iteration ${ITER} --description "Tinc VPN Daemon" -d "lzo" -d "zlib" -d "openssl" -f --after-install post-install -C tmp/build .

rm -Rf tmp/build

