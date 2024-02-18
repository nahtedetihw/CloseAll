TARGET := iphone:clang:latest:14.4
INSTALL_TARGET_PROCESSES = SpringBoard

DEBUG = 0

FINALPACKAGE = 1
THEOS_PACKAGE_SCHEME=rootless

##SYSROOT=$(THEOS)/sdks/iPhoneOS14.5.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CloseAll

CloseAll_FILES = Tweak.xm CloseAllManager.xm
CloseAll_CFLAGS = -fobjc-arc -Wno-module-import-in-extern-c

include $(THEOS_MAKE_PATH)/tweak.mk
