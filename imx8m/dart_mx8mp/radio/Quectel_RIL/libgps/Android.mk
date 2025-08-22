LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := android.hardware.gnss-service.example
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_PREBUILT_MODULE_FILE := $(LOCAL_PATH)/android.hardware.gnss-service.example
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/bin/hw
LOCAL_SHARED_LIBRARIES := android.hardware.gnss-V2-ndk libbase libbinder_ndk libc++ libcutils libhardware liblog libutils
LOCAL_MODULE_TAGS := optional
LOCAL_VENDOR_MODULE := true

LOCAL_VINTF_FRAGMENTS := gnss-default.xml
LOCAL_INIT_RC := gnss-default.rc
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE := gps.default.so
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_PREBUILT_MODULE_FILE := $(LOCAL_PATH)/gps.default.so
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib64/hw
LOCAL_SHARED_LIBRARIES := libc++ libc libcutils libdl liblog libm
LOCAL_MODULE_TAGS := optional
LOCAL_VENDOR_MODULE := true
include $(BUILD_PREBUILT)
