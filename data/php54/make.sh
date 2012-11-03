echo PKG_ROOT = "${PKG_ROOT}"
echo PKG_WORK = "${PKG_WORK}"
echo PKG_DATA = "${PKG_DATA}"
echo PKG_DEST = "${PKG_DEST}"
echo PKG_TARG = "${PKG_TARG}"

pkg:setup

#Cross compiling patch for msqlnd : http://chris.losari.org/2012/06/cross-compile-php-for-arm.html
cd ext/mysqlnd
sed -ie "s{ext/mysqlnd/php_mysqlnd_config.h{config.h{" mysqlnd_portability.h
cd ../..
#Patch-End

#export EXTENSION_DIR="${PKG_DEST}"/usr/local/lib/php/extensions/no-debug-non-zts-20100525
export INSTALL_ROOT="${PKG_DEST}"

autoconf-2.69 
export CC="${PKG_TARG}"-gcc 
pkg:configure  --prefix=/usr/local --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --without-pear --enable-calendar=shared --with-iconv=shared,"${PKG_ROOT}"/usr --with-curl=shared,"$(PKG_DEST_ curl)"/usr --enable-exif=shared --with-gd=shared --enable-gd-native-ttf --with-jpeg-dir="$(PKG_DEST_ _libjpeg)"/usr --with-png-dir="$(PKG_DEST_ _libpng)"/usr --with-pdo --with-sqlite3=shared --with-pdo-sqlite=shared --enable-mysqlnd=shared --with-pdo-mysql=shared,mysqlnd --with-mysql=shared,mysqlnd --with-mysqli=shared,mysqlnd --enable-mbstring=shared --with-mcrypt=shared,"$(PKG_DEST_ _libmcrypt)"/usr --with-zlib-dir --enable-zip=shared --with-bz2=shared --with-openssl=shared,"$(PKG_DEST_ openssl)"/usr --enable-gd-jis-conv --with-xsl=shared,"$(PKG_DEST_ libxslt)"/usr 


#Bad news: It could be that 'configure' found the host system libxml2 libs and includes!
#Regarding the define of LIBXML_VERSION we need the LIBXML2 include files 
#from the SDK  and not the files from telesphoreo or from the host. 
#Fastest solution -> we have to change the libxml2 search path in Makefile
sed -ie "s{-I/usr/include/libxml2{-I${PKG_ROOT}/usr/include/libxml2 -I${PKG_ROOT}/usr/include/libxml2/libxml{" Makefile

make  
#make install prefix="${PKG_DEST}"/usr/local datarootdir="${PKG_DEST}"/usr/local/share
make install


#Clean up and polish a little bit
#================================

#Delete man pages
rm -r ${PKG_DEST}//usr/local/php

#Delete static extension files
cd ${PKG_DEST}/usr/local/lib/php/extensions/no-debug-non-zts-20100525
rm *.a

#Compress PHP header files and then delete the whole header folder
cd ${PKG_DEST}/usr/local/include
tar cvfj php_all_headers.tar.bz2 php
rm -r php/*
mv  php_all_headers.tar.bz2 php/


#We have to adjust a path in phar.phar
cd ${PKG_DEST}/usr/local/bin
sed -i 's\#!.*\#!/usr/local/bin/php\g' phar.phar

#Telesphoreo creats a bad symbolic link to phar.
#We have to change it...
cd ${PKG_DEST}/usr/local/bin
rm phar
ln -s phar.phar ./phar


