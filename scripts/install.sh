#!/bin/bash
#
# install
#
# This script must be run from the Android main directory.
#
# Variscite DART-MX8M patches for Android 12.0.0 1.0.0

set -e
#set -x

SCRIPT_NAME=${0##*/}
readonly SCRIPT_VERSION="0.1"

#### Exports Variables ####
#### global variables ####
readonly ABSOLUTE_FILENAME=$(readlink -e "$0")
readonly ABSOLUTE_DIRECTORY=$(dirname ${ABSOLUTE_FILENAME})
readonly SCRIPT_POINT=${ABSOLUTE_DIRECTORY}
readonly SCRIPT_START_DATE=$(date +%Y%m%d)
readonly ANDROID_DIR="${SCRIPT_POINT}/../../.."
readonly G_CROSS_COMPILER_PATH=${ANDROID_DIR}/prebuilts/gcc/linux-x86/aarch64/gcc-arm-8.3-2019.03-x86_64-aarch64-elf
readonly G_CROSS_COMPILER_ARCHIVE=gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz
readonly G_VARISCITE_URL="https://variscite-public.nyc3.cdn.digitaloceanspaces.com"
readonly G_EXT_CROSS_COMPILER_LINK="${G_VARISCITE_URL}/Android/Android_iMX8_Q1000_230/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz"
readonly C_LANG_LINK="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86"
readonly C_LANG_DIR="/opt/prebuilt-android-clang-var-bceb7274dda5b/"

readonly BASE_BRANCH_NAME="android-14.0.0_1.0.0"

## git variables get from base script!
readonly _EXTPARAM_BRANCH="android-14.0.0_1.0.0-var01"

## dirs ##
readonly VARISCITE_PATCHS_DIR="${SCRIPT_POINT}/platform"
readonly VARISCITE_SH_DIR="${SCRIPT_POINT}/sh"
VENDOR_BASE_DIR=${ANDROID_DIR}/vendor/variscite
LIBBT=$(readlink -f "${ANDROID_DIR}/hardware/broadcom/libbt")
SEPOLICY=$(readlink -f "${ANDROID_DIR}/system/sepolicy")

SC_MX8_FAMILY=$1
readonly SCFW_BRANCH="1.6.0"
readonly SRCREV_8X="0dbb2964afbb50f9b48d0955e7d5ef7d9cbabe23"
readonly SRCREV_8M="9626cacced29ffa24b06847f1e54fc4eb137a282"
readonly GCC_ARM_NONE_EABI_MD5SUM="f55f90d483ddb3bcf4dae5882c2094cd"
readonly GCC_ARM_NONE_TOOL="gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2"
readonly PRE_BUILTS_GCC_PATH=${ANDROID_DIR}/prebuilts/gcc/linux-x86/aarch64/

# print error message
# p1 - printing string
function pr_error() {
	echo ${2} "E: $1"
}

# print warning message
# p1 - printing string
function pr_warning() {
	echo ${2} "W: $1"
}

# print info message
# p1 - printing string
function pr_info() {
	echo ${2} "I: $1"
}

# print debug message
# p1 - printing string
function pr_debug() {
	echo ${2} "D: $1"
}

# test existing brang in git repo
# p1 - git folder
# p2 - branch name
function is_branch_exist()
{
	local D="${1}"
	local B="${2}"
	local B_found
	local HERE

	if [ \( ! -d "${D}" \) -o \( -z "${B}" \) ]; then
		echo false
		return
	fi

	HERE=${PWD}
	cd "${D}" > /dev/null

	# Check branch
	git branch 2>&1 > /dev/null
	if [ ${?} -ne 0 ]; then
		echo false
		cd ${HERE} > /dev/null
		return
	fi
	B_found=$(git branch | grep -w "${B}")
	if [ -z "${B_found}" ]; then
		echo false
	else
		echo true
	fi

	cd ${HERE} > /dev/null
	return
}

#Download SCFW and tools
function scfw_tools_setup()
{
	pr_info "####################################"
	pr_info "# Copy SCFW FW code and tool chain #"
	pr_info "####################################"

	case $1 in
	      $"qx")
		SRCREV=${SRCREV_8X}
	   ;;
	      $"qm")
		SRCREV=${SRCREV_8M}
	   ;;
	*)
	esac

	cd ${PRE_BUILTS_GCC_PATH}
	if [[ ! -d "imx-sc-firmware" ]] ; then
		git clone git://github.com/varigit/imx-sc-firmware.git
	fi

	if [[ ! -f ${PRE_BUILTS_GCC_PATH}/${GCC_ARM_NONE_TOOL} ]] ; then
		wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2018q4/${GCC_ARM_NONE_TOOL}
	fi

	checksum=`md5sum ${GCC_ARM_NONE_TOOL} | awk '{ print $1 }'`

	if [[ ${GCC_ARM_NONE_EABI_MD5SUM} = ${checksum} ]]; then
		tar xf ${GCC_ARM_NONE_TOOL}
	else
		echo; red_bold_echo "Bad md5sum for ${GCC_ARM_NONE_TOOL}"
		exit 1
	fi

	cd imx-sc-firmware/
	existed_in_local=$(git branch --list ${SCFW_BRANCH})
	if [[ -z ${existed_in_local} ]]; then
		git checkout ${SRCREV} -b ${SCFW_BRANCH}
	else
	    echo "${SCFW_BRANCH} already exists"
	fi
}

############### main code ##############
pr_info "Script version ${SCRIPT_VERSION} (g:20210409)"

cd ${ANDROID_DIR} > /dev/null
pr_info "###########################"
pr_info "# Apply framework patches #"
pr_info "###########################"
cd ${VARISCITE_PATCHS_DIR} > /dev/null
git_array=$(find * -type d | grep '.git')
cd - > /dev/null

for _ddd in ${git_array}
do
	_git_p=$(echo ${_ddd} | sed 's/.git//g')
	cd ${ANDROID_DIR}/${_git_p}/ > /dev/null

	if [[ `git branch --list $_EXTPARAM_BRANCH` ]] ; then
		if [[ ${PWD} == ${LIBBT} ]] || [[ ${PWD} == ${SEPOLICY} ]]; then
			git checkout tags/android-14.0.0_r17
		else
			git checkout tags/${BASE_BRANCH_NAME}
		fi
		git branch -D ${_EXTPARAM_BRANCH}
		git checkout -b ${_EXTPARAM_BRANCH} || {
			pr_warning "Branch ${_EXTPARAM_BRANCH} is present!"
		};

	else
		git checkout -b ${_EXTPARAM_BRANCH} || {
			pr_warning "Branch ${_EXTPARAM_BRANCH} is present!"
		};
	fi

	pr_info "Apply patches for this git: \"${_git_p}/\""
	git am ${VARISCITE_PATCHS_DIR}/${_ddd}/*

	cd - > /dev/null
done

pr_info "#######################"
pr_info "# Copy shell utilites #"
pr_info "#######################"
cp -r ${VARISCITE_SH_DIR}/* ${ANDROID_DIR}/

pr_info "#######################"
pr_info "# Copy ARM tool chain #"
pr_info "#######################"
# get arm toolchain
(( `ls ${G_CROSS_COMPILER_PATH} 2>/dev/null | wc -l` == 0 )) && {
	pr_info "Get and unpack cross compiler";
	cd ${ANDROID_DIR}/prebuilts/gcc/linux-x86/aarch64/
	wget ${G_EXT_CROSS_COMPILER_LINK}
	tar -xJf ${G_CROSS_COMPILER_ARCHIVE} \
		-C .
};

pr_info "#######################"
pr_info "# Clang setup #"
pr_info "#######################"
if [[ ! -d ${C_LANG_DIR} ]] ; then
	sudo git clone ${C_LANG_LINK} ${C_LANG_DIR} -b master
	cd ${C_LANG_DIR}
	sudo git checkout bceb7274dda5bb587a5473058bd9f52e678dde98
fi

if [[ ! -z $SC_MX8_FAMILY ]] ; then
	scfw_tools_setup ${SC_MX8_FAMILY}
fi

pr_info "#####################"
pr_info "# Done             #"
pr_info "#####################"

exit 0
