TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

DEBUG = 0

FINALPACKAGE = 1
## THEOS_PACKAGE_SCHEME=rootless

SYSROOT=$(THEOS)/sdks/iphoneos14.5.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CloseAll

CloseAll_FILES = Tweak.xm CloseAllManager.xm
CloseAll_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
