export TARGET=iphone:clang
ARCHS = armv7 arm64
DEBUG = 1
# PACKAGE_VERSION = 1.1

THEOS=/opt/theos

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Countdown
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_LDFLAGS += -F./
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Settings
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
