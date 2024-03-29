# -------@block_infrastructure-------
#
# Product-specific compile-time definitions.
#

include $(CONFIG_REPO_PATH)/imx8m/BoardConfigCommon.mk

# -------@block_common_config-------
#
# SoC-specific compile-time definitions.
#

BOARD_SOC_TYPE := IMX8MP
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := hantro
HAVE_FSL_IMX_GPU2D := false
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_PXP := false
TARGET_USES_HWC2 := true
TARGET_HAVE_VULKAN := true
CFG_SECURE_IOCTRL_REGS := true
ENABLE_SEC_DMABUF_HEAP := true

SOONG_CONFIG_IMXPLUGIN += \
                        BOARD_VPU_TYPE \
                        CFG_SECURE_IOCTRL_REGS \
                        ENABLE_SEC_DMABUF_HEAP

SOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = IMX8MP
SOONG_CONFIG_IMXPLUGIN_BOARD_HAVE_VPU = true
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_TYPE = hantro
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_ONLY = false
SOONG_CONFIG_IMXPLUGIN_PREBUILT_FSL_IMX_CODEC = true
SOONG_CONFIG_IMXPLUGIN_POWERSAVE = $(POWERSAVE)
SOONG_CONFIG_IMXPLUGIN_CFG_SECURE_IOCTRL_REGS = true
SOONG_CONFIG_IMXPLUGIN_ENABLE_SEC_DMABUF_HEAP = true

# -------@block_memory-------
USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# -------@block_storage-------
TARGET_USERIMAGES_USE_EXT4 := true

# use sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

# Support gpt
ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
  BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab_super.bpt
  ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab_super.bpt \
                           partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-dual-bootloader_super.bpt \
                           partition-table-28GB-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-dual-bootloader_super.bpt
else
  ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
    BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-no-product.bpt
    ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-no-product.bpt \
                             partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-dual-bootloader-no-product.bpt \
                             partition-table-28GB-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-dual-bootloader-no-product.bpt
  else
    BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab.bpt
    ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab.bpt \
                             partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-dual-bootloader.bpt \
                             partition-table-28GB-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-dual-bootloader.bpt
  endif
endif

# These variables are used to specify the dtbo and boot images to include in the OTA package.
# Modify the value of these variables to fit your requirement.
BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8mp-var-dart-dt8mcustomboard.img
ifeq ($(TARGET_IMX_KERNEL),false)
BOARD_PREBUILT_BOOTIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/boot-imx.img
endif

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

ifneq ($(BUILD_ENCRYPTED_BOOT),true)
  AB_OTA_PARTITIONS += bootloader
endif

# -------@block_security-------
ENABLE_CFI=true

BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
# The testkey_rsa4096.pem is copied from external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_KEY_PATH := $(CONFIG_REPO_PATH)/common/security/testkey_rsa4096.pem

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

# Enable chained vbmeta for init_boot images
BOARD_AVB_INIT_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_INIT_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX_LOCATION := 3

# Use sha256 hashtree
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256

# -------@block_treble-------
# Vendor Interface manifest and compatibility
ifeq ($(POWERSAVE),true)
    DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest_powersave.xml
else
    DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
endif

DEVICE_MATRIX_FILE := $(NXP_DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(NXP_DEVICE_PATH)/device_framework_matrix.xml

# -------@block_wifi-------
# Sterling LWB / LWB5 WiFi
BOARD_WLAN_DEVICE            := bcmdhd
# NXP 8997 WIFI
#BOARD_WLAN_DEVICE            := nxp
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

# -------@block_bluetooth-------
# Sterling LWB / LWB5 BT via HCI UART driver
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

# NXP 8997 BT
#BOARD_HAVE_BLUETOOTH_NXP := true

# -------@block_sensor-------
#BOARD_USE_SENSOR_FUSION := true

# -------@block_kernel_bootimg-------
BOARD_KERNEL_BASE := 0x40400000

ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
    TARGET_BOARD_DTS_CONFIG := \
	 imx8mp-var-dart-dt8mcustomboard:imx8mp-var-dart-dt8mcustomboard.dtb \
	 imx8mp-var-dart-dt8mcustomboard-m7:imx8mp-var-dart-dt8mcustomboard-m7.dtb \
	 imx8mp-var-dart-dt8mcustomboard-basler-isp0:imx8mp-var-dart-dt8mcustomboard-basler-isp0.dtb \
	 imx8mp-var-dart-dt8mcustomboard-basler-isp0-m7:imx8mp-var-dart-dt8mcustomboard-basler-isp0-m7.dtb \
	 imx8mp-var-dart-dt8mcustomboard-basler-isi0:imx8mp-var-dart-dt8mcustomboard-basler-isi0.dtb \
	 imx8mp-var-dart-dt8mcustomboard-basler-isi0-m7:imx8mp-var-dart-dt8mcustomboard-basler-isi0-m7.dtb \
	 imx8mp-var-som-symphony:imx8mp-var-som-symphony.dtb \
	 imx8mp-var-som-symphony-m7:imx8mp-var-som-symphony-m7.dtb \
	 imx8mp-var-som-symphony-2nd-ov5640:imx8mp-var-som-symphony-2nd-ov5640.dtb \
	 imx8mp-var-som-symphony-2nd-ov5640-m7:imx8mp-var-som-symphony-2nd-ov5640-m7.dtb \
	 imx8mp-var-som-symphony-basler-isp0:imx8mp-var-som-symphony-basler-isp0.dtb \
	 imx8mp-var-som-symphony-basler-isp0-m7:imx8mp-var-som-symphony-basler-isp0-m7.dtb \
	 imx8mp-var-som-symphony-basler-isi0:imx8mp-var-som-symphony-basler-isi0.dtb \
	 imx8mp-var-som-symphony-basler-isi0-m7:imx8mp-var-som-symphony-basler-isi0-m7.dtb \
	 imx8mp-var-som-1.x-symphony:imx8mp-var-som-1.x-symphony.dtb \
	 imx8mp-var-som-1.x-symphony-m7:imx8mp-var-som-1.x-symphony-m7.dtb \
	 imx8mp-var-som-1.x-symphony-2nd-ov5640:imx8mp-var-som-1.x-symphony-2nd-ov5640.dtb \
	 imx8mp-var-som-1.x-symphony-2nd-ov5640-m7:imx8mp-var-som-1.x-symphony-2nd-ov5640-m7.dtb \
	 imx8mp-var-som-1.x-symphony-basler-isp0:imx8mp-var-som-1.x-symphony-basler-isp0.dtb \
	 imx8mp-var-som-1.x-symphony-basler-isp0-m7:imx8mp-var-som-1.x-symphony-basler-isp0-m7.dtb \
	 imx8mp-var-som-1.x-symphony-basler-isi0:imx8mp-var-som-1.x-symphony-basler-isi0.dtb \
	 imx8mp-var-som-1.x-symphony-basler-isi0-m7:imx8mp-var-som-1.x-symphony-basler-isi0-m7.dtb \
	 imx8mp-var-som-wbe-symphony:imx8mp-var-som-wbe-symphony.dtb \
	 imx8mp-var-som-wbe-symphony-m7:imx8mp-var-som-wbe-symphony-m7.dtb \
	 imx8mp-var-som-wbe-symphony-2nd-ov5640:imx8mp-var-som-wbe-symphony-2nd-ov5640.dtb \
	 imx8mp-var-som-wbe-symphony-2nd-ov5640-m7:imx8mp-var-som-wbe-symphony-2nd-ov5640-m7.dtb \
	 imx8mp-var-som-wbe-symphony-basler-isp0:imx8mp-var-som-wbe-symphony-basler-isp0.dtb \
	 imx8mp-var-som-wbe-symphony-basler-isp0-m7:imx8mp-var-som-wbe-symphony-basler-isp0-m7.dtb \
	 imx8mp-var-som-wbe-symphony-basler-isi0:imx8mp-var-som-wbe-symphony-basler-isi0.dtb \
	 imx8mp-var-som-wbe-symphony-basler-isi0-m7:imx8mp-var-som-wbe-symphony-basler-isi0-m7.dtb
endif

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

# -------@block_sepolicy-------
BOARD_SEPOLICY_DIRS := \
       $(CONFIG_REPO_PATH)/imx8m/sepolicy \
       $(NXP_DEVICE_PATH)/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

BOARD_BOOTCONFIG += \
       androidboot.vendor.apex.com.google.android.widevine=com.google.android.widevine
