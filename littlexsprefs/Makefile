include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = littlexsprefs
littlexsprefs_FILES = LXSRootListController.m
littlexsprefs_INSTALL_PATH = /Library/PreferenceBundles
littlexsprefs_FRAMEWORKS = UIKit
littlexsprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/littlexsprefs.plist$(ECHO_END)
