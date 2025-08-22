LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := libril
LOCAL_INSTALLED_MODULE_STEM := libril.so
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib64
LOCAL_PREBUILT_MODULE_FILE := $(LOCAL_PATH)/libril.so
LOCAL_SHARED_LIBRARIES := android.hardware.radio.config-V1-ndk android.hardware.radio.data-V1-ndk \
android.hardware.radio.messaging-V1-ndk android.hardware.radio.modem-V1-ndk android.hardware.radio.network-V1-ndk \
android.hardware.radio.sim-V1-ndk android.hardware.radio.voice-V1-ndk libbase libbinder_ndk libc++ libc libcutils libdl \
libhardware_legacy liblog libm librilutils libutils
LOCAL_VINTF_FRAGMENTS := manifest.radio.xml
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_TAGS := optional
#LOCAL_CHECK_ELF_FILES := false

include $(BUILD_PREBUILT)
