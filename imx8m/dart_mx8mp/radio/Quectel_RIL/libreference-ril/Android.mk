LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libreference-ril.so
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_PREBUILT_MODULE_FILE := $(LOCAL_PATH)/libreference-ril.so
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib64/
#LOCAL_SHARED_LIBRARIES := libc++ libc libcutils libdl liblog libm libnetutils libril libutils
LOCAL_CHECK_ELF_FILES := false
LOCAL_MODULE_TAGS := optional
LOCAL_VENDOR_MODULE := true
include $(BUILD_PREBUILT)
