#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";
curr=$PWD;
#git pull origin master;

if [ ! -d "tmp" ]; then
	mkdir tmp;
fi

function  backup() {
	ls -a ~ | tail -n +3 > tmp/old;
	ls -a . | tail -n +3 | grep -v -w 'tmp' > tmp/new;
	commFiles=$(comm -12 tmp/old tmp/new);
	pushd ~;
	echo $commFiles | xargs tar -zcvf "$curr/tmp/backup.tar.gz";
	echo "$curr/tmp/backup.tar.gz generated";
	popd;
}

function doIt() {
	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
		--exclude "README.md" --exclude "LICENSE-MIT.txt" --exclude "tmp/" \
		-avh --no-perms . ~;
	source ~/.bash_profile;
}

function restore() {
	pushd tmp/;
	if [ -e 'backup.tar.gz' ]; then
		rm -rf backup/;
		mkdir backup;
		tar -zxvf 'backup.tar.gz' -C backup;
		ls -a backup/ | tail -n +3 > backup.data;
		pushd backup/;
		rsync -avh --no-perms . ~;
		source ~/.bash_profile;
		popd;
		extraFiles=$(comm -13 backup.data new)
		cd ~;
		rm -i -r $extraFiles;
		# mark! to do: delete extra files
		exit 0;
	else
		echo "Cannot find backup file.";
		exit 1;
	fi
}
if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
elif [ "$1" == "--restore" -o "$1" == "-r" ]; then
	echo "restore...";
	restore;
else
	backup;
	doIt;
fi;
unset doIt;
