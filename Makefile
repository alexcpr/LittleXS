FINALPACKAGE=1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LittleXS
LittleXS_FILES = Tweak.xm
LittleXS_LIBRARIES = MobileGestalt
LittleXS_CFLAGS = -fobjc-arc
ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += littlexsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
