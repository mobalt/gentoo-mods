# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit eutils desktop

SLOT="0"
BUILD_VER="$(ver_cut 4-6)"
MY_PV="$(ver_cut 1-3)"

KEYWORDS="amd64 ~x86"
SRC_URI="
community? (
	custom-jdk? ( https://download.jetbrains.com/idea/ideaIC-${MY_PV}.tar.gz )
	!custom-jdk? ( https://download.jetbrains.com/idea/ideaIC-${MY_PV}-no-jdk.tar.gz )
)
!community? (
	custom-jdk? ( https://download.jetbrains.com/idea/ideaIU-${MY_PV}.tar.gz )
	!custom-jdk? ( https://download.jetbrains.com/idea/ideaIU-${MY_PV}-no-jdk.tar.gz )
)
"

DESCRIPTION="A complete toolset for web, mobile and enterprise development"
HOMEPAGE="https://www.jetbrains.com/idea"

LICENSE="
	!community? ( Commercial )
	community? ( Apache-2.0 )
	custom-jdk? ( GPL-2 )"
IUSE="-custom-jdk -community"
DEPEND="!dev-util/idea-ultimate
	!dev-util/idea-community"
RDEPEND="${DEPEND}
	>=virtual/jdk-1.7:*"
S="${WORKDIR}/idea-IU-${BUILD_VER}"

QA_PREBUILT="opt/${PN}-${BUILD_VER}/*"

src_prepare() {
	if use community; then
		S="${WORKDIR}/idea-IC-${BUILD_VER}"
	fi
	eapply_user
	if ! use amd64; then
		rm -r plugins/tfsIntegration/lib/native/linux/x86_64 || die
	fi
	if ! use arm; then
		rm bin/fsnotifier-arm || die
		rm -r plugins/tfsIntegration/lib/native/linux/arm || die
	fi
	if ! use ppc; then
		rm -r plugins/tfsIntegration/lib/native/linux/ppc || die
	fi
	if ! use x86; then
		rm -r plugins/tfsIntegration/lib/native/linux/x86 || die
	fi
	if ! use custom-jdk; then
		if [[ -d jre ]]; then
			rm -r jre || die
		fi
		if [[ -d jre64 ]]; then
			rm -r jre64 || die
		fi
	fi
	rm -r plugins/tfsIntegration/lib/native/solaris || die
	rm -r plugins/tfsIntegration/lib/native/hpux || die
}

src_install() {
	local dir="/opt/${PN}-${BUILD_VER}"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/bin/{format.sh,idea.sh,inspect.sh,printenv.py,restart.py,fsnotifier{,64}}

	if use custom-jdk; then
		if [[ -d jre ]]; then
			fperms 755 "${dir}"/jre/jre/bin/{java,jjs,keytool,orbd,pack200,policytool,rmid,rmiregistry,servertool,tnameserv,unpack200}
		fi
		if [[ -d jre64 ]]; then
			fperms 755 "${dir}"/jre64//bin/{java,jjs,keytool,orbd,pack200,policytool,rmid,rmiregistry,servertool,tnameserv,unpack200}
		fi
	fi

	make_wrapper "${PN}" "${dir}/bin/idea.sh"
	newicon "bin/idea.png" "${PN}.png"
	make_desktop_entry "${PN}" "IntelliJ Idea" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	mkdir -p "${D}/etc/sysctl.d/" || die
	echo "fs.inotify.max_user_watches = 524288" > "${D}/etc/sysctl.d/30-idea-inotify-watches.conf" || die
}
