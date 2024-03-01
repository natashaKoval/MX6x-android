#!/bin/bash

# hardcode this one again in this shell script
CONFIG_REPO_PATH=device/variscite

# import other paths in the file "common/imx_path/ImxPathConfig.mk" of this
# repository

while read -r line
do
	if [ "$(echo ${line} | grep "=")" != "" ]; then
		env_arg=`echo ${line} | cut -d "=" -f1`
		env_arg=${env_arg%:}
		env_arg=`eval echo ${env_arg}`

		env_arg_value=`echo ${line} | cut -d "=" -f2`
		env_arg_value=`eval echo ${env_arg_value}`

		eval ${env_arg}=${env_arg_value}
	fi
done < ${CONFIG_REPO_PATH}/common/imx_path/ImxPathConfig.mk

if [ "${AARCH64_GCC_CROSS_COMPILE}" != "" ]; then
	ATF_CROSS_COMPILE=`eval echo ${AARCH64_GCC_CROSS_COMPILE}`
else
	echo ERROR: \*\*\* env AARCH64_GCC_CROSS_COMPILE is not set
	exit 1
fi

build_m4_image()
{
        :
}

build_imx_uboot()
{
	echo Building i.MX U-Boot with firmware
	cp ${UBOOT_OUT}/u-boot-nodtb.$1 ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	cp ${UBOOT_OUT}/spl/u-boot-spl.bin  ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	cp ${UBOOT_OUT}/tools/mkimage  ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/mkimage_uboot
	cp ${UBOOT_OUT}/arch/arm/dts/imx8mp-var-dart-dt8mcustomboard.dtb ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	cp ${UBOOT_OUT}/arch/arm/dts/imx8mp-var-som-symphony.dtb ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	cp ${FSL_PROPRIETARY_PATH}/linux-firmware-imx/firmware/ddr/synopsys/lpddr4_pmu_train* ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/

	# build ATF based on whether tee is involved
	make -C ${IMX_PATH}/arm-trusted-firmware/ PLAT=`echo $2 | cut -d '-' -f1` clean
	if [ "`echo $2 | cut -d '-' -f2`" = "trusty" ]; then
		cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/uboot-firmware/imx8m/tee-imx8mp.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin
		make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=`echo $2 | cut -d '-' -f1` bl31 -B SPD=trusty IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
	else
		if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin ] ; then
			rm -rf ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin
		fi
		if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin.lz4 ] ; then
			rm -rf ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin.lz4
		fi
		make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=`echo $2 | cut -d '-' -f1` bl31 -B IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
	fi
	cp ${IMX_PATH}/arm-trusted-firmware/build/`echo $2 | cut -d '-' -f1`/release/bl31.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/bl31.bin

	make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ clean
	make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MP flash_evk || exit 1
	cp ${UBOOT_OUT}/arch/arm/dts/imx8mp-var-dart-dt8mcustomboard.dtb ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	cp ${UBOOT_OUT}/arch/arm/dts/imx8mp-var-som-symphony.dtb ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MP print_fit_hab || exit 1
	cp ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/flash.bin ${UBOOT_COLLECTION}/u-boot-$2.imx
}
