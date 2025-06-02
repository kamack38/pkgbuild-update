#!/bin/bash
set -o errexit -o pipefail -o nounset
shopt -s extglob

# Set path
WORKPATH=$GITHUB_WORKSPACE/$INPUT_PATH
HOME=/home/builder
BUILDPATH="$HOME/gh-action"
echo "::group::Copying files from $WORKPATH to $BUILDPATH"

# Set path permision
mkdir -p $BUILDPATH
cd $BUILDPATH
cp -rfv "$GITHUB_WORKSPACE"/.git ./
cp -fv "$WORKPATH"/* ./
echo "::endgroup::"

# Update pkgver
OLD_PKGVER=$(sed -n "s:^pkgver=\(.*\):\1:p" PKGBUILD)

# Fix permisions for output
sudo chmod 777 $GITHUB_OUTPUT
echo "old_pkgver=$OLD_PKGVER" >>$GITHUB_OUTPUT
if [[ -n $INPUT_PKGVER ]]; then
	NEW_PKGVER="$INPUT_PKGVER"
	echo "::group::Updating pkgver on PKGBUILD from $OLD_PKGVER to $NEW_PKGVER"
	sed -i "s:^pkgver=.*$:pkgver=$INPUT_PKGVER:g" PKGBUILD
	git diff PKGBUILD
	echo "::endgroup::"
else
	# Install make depends using paru from aur
	if [[ $INPUT_PARU == true ]]; then
		echo "::group::Installing make dependcies using paru"
		set +o nounset
		source PKGBUILD
		set -o nounset
		paru -Syu --needed --noconfirm "${makedepends[@]}"
		echo "::endgroup::"
	fi

	# Update package version
	echo "::group::Running makepkg -do"
	makepkg -do --noconfirm
	echo "::endgroup::"
	NEW_PKGVER=$(sed -n "s:^pkgver=\(.*\):\1:p" PKGBUILD)
	echo "new_pkgver=$NEW_PKGVER" >>$GITHUB_OUTPUT
fi

echo "new_pkgver=$NEW_PKGVER" >>$GITHUB_OUTPUT

# Update pkgrel
OLD_PKGREL=$(sed -n "s:^pkgrel=\(.*\):\1:p" PKGBUILD)
echo "old_pkgrel=$OLD_PKGREL" >>$GITHUB_OUTPUT
if [[ -n $INPUT_PKGREL ]]; then
	NEW_PKGREL=$INPUT_PKGREL
	echo "::group::Updating pkgrel on PKGBUILD from $OLD_PKGREL to $NEW_PKGREL"
	sed -i "s:^pkgrel=.*$:pkgrel=$NEW_PKGREL:g" PKGBUILD
	git diff PKGBUILD
	echo "::endgroup::"
else
	NEW_PKGREL=$OLD_PKGREL
fi
echo "new_pkgrel=$NEW_PKGREL" >>$GITHUB_OUTPUT

# Clean build directory
echo "::group::Cleaning build directory"
for item in *; do
	if [ ! -f "$WORKPATH/$item" ]; then
		rm -rvf "$item"
	fi
done

# List remaining files
ls -a
echo "::endgroup::"

# Update checksums
if [[ $INPUT_UPDPKGSUMS == true ]]; then
	echo "::group::Updating checksums on PKGBUILD"
	updpkgsums
	git diff PKGBUILD
	echo "::endgroup::"

	echo "::group::Cleaning downloaded files"
	for item in *; do
		if [ ! -f "$WORKPATH/$item" ]; then
			rm -rvf "$item"
		fi
	done

	# List remaining files
	ls -a
	echo "::endgroup::"
fi

# Generate .SRCINFO
if [[ $INPUT_SRCINFO == true ]]; then
	echo "::group::Generating new .SRCINFO based on PKGBUILD"
	makepkg --printsrcinfo >.SRCINFO
	git diff .SRCINFO
	echo "::endgroup::"
fi

echo "::group::Copying files from $BUILDPATH to $WORKPATH"
sudo cp -fv "$BUILDPATH"/* "$WORKPATH"
echo "::endgroup::"

# Build the new package
if [[ $INPUT_BUILD == true ]]; then
	# Install dependcies using paru
	if [[ $INPUT_PARU == true ]]; then
		echo "::group::Installing dependcies using paru"
		set +o nounset
		source PKGBUILD
		set -o nounset
		paru -Syu --needed --noconfirm "${depends[@]}" "${makedepends[@]}"
		echo "::endgroup::"
	fi

	# Build the package
	echo "::group::Running makepkg with flags ($INPUT_FLAGS)"
	makepkg "$INPUT_FLAGS"
	echo "::endgroup::"
fi

# Push the package to aur
INPUT_AUR_COMMIT_MESSAGE=$(
	echo "$INPUT_AUR_COMMIT_MESSAGE" | sed "s/\\\$AUR_PKGNAME/$INPUT_AUR_PKGNAME/g;
	s/\\\$OLD_PKGVER/$OLD_PKGVER/g;
	s/\\\$NEW_PKGVER/$NEW_PKGVER/g"
)
if [[ -z $INPUT_AUR_PKGNAME ]]; then
	echo "::group::Setting AUR package name"
	set +o nounset
	source PKGBUILD
	set -o nounset
	if [[ -n ${pkgbase:-} ]]; then
		INPUT_AUR_PKGNAME="$pkgbase"
	else
		INPUT_AUR_PKGNAME="$pkgname"
	fi
	echo "The package name was set to '$INPUT_AUR_PKGNAME'"
	echo "::endgroup::"
fi
if [[ -n $INPUT_AUR_PKGNAME && -n $INPUT_AUR_SSH_PRIVATE_KEY && -n $INPUT_AUR_COMMIT_EMAIL && -n $INPUT_AUR_COMMIT_USERNAME && -n $INPUT_AUR_COMMIT_MESSAGE ]]; then
	echo "::group::Adding aur.archlinux.org to known hosts"
	touch $HOME/.ssh/known_hosts
	ssh-keyscan -v -t 'rsa,ecdsa,ed25519' aur.archlinux.org >>~/.ssh/known_hosts
	echo "::endgroup::"

	echo "::group::Importing private key"
	echo "$INPUT_AUR_SSH_PRIVATE_KEY" >~/.ssh/aur
	chmod -vR 600 ~/.ssh/aur*
	ssh-keygen -vy -f ~/.ssh/aur >~/.ssh/aur.pub
	echo "::endgroup::"

	echo "::group::Checksums of SSH keys"
	sha512sum ~/.ssh/aur ~/.ssh/aur.pub
	echo "::endgroup::"

	echo "::group::Configuring Git"
	git config --global user.name "$INPUT_AUR_COMMIT_USERNAME"
	git config --global user.email "$INPUT_AUR_COMMIT_EMAIL"
	echo "::endgroup::"

	AUR_REPO_URL="https://aur.archlinux.org/${INPUT_AUR_PKGNAME}.git"
	echo "::group::Cloning https://aur.archlinux.org/${INPUT_AUR_PKGNAME}.git into /tmp/aur-repo"
	git clone -v "$AUR_REPO_URL" /tmp/aur-repo
	echo "::endgroup::"

	echo "::group::Copying files into /tmp/aur-repo"
	cp -fva "$WORKPATH/." /tmp/aur-repo
	echo "::endgroup::"

	echo "::group::Generating new .SRCINFO based on PKGBUILD"
	cd /tmp/aur-repo
	makepkg --printsrcinfo >.SRCINFO
	cat .SRCINFO
	echo "::endgroup::"

	echo "::group::Committing files to the repository"
	git add --all
	ls -al
	git diff-index --quiet HEAD || git commit -m "$INPUT_AUR_COMMIT_MESSAGE" # use `git diff-index --quiet HEAD ||` to avoid error
	echo "::endgroup::"

	echo "::group::Publishing the repository"
	git remote add aur "ssh://aur@aur.archlinux.org/${INPUT_AUR_PKGNAME}.git"
	case "$INPUT_AUR_FORCE_PUSH" in
	true)
		git push -v --force aur master
		;;
	false)
		git push -v aur master
		;;
	*)
		echo "::error::Invalid Value: inputs.force_push is neither 'true' nor 'false': '$force_push'"
		exit 3
		;;
	esac
	echo "::endgroup::"
fi
