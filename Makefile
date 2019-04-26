FINALPACKAGE=1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LittleXS
LittleXS_FILES = Tweak.xm
LittleXS_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += littlexsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
