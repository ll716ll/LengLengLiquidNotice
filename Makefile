THEOS_PACKAGE_SCHEME = rootless
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LengLengLiquidNotice
LengLengLiquidNotice_FILES = Tweak.xm LLNView.m
LengLengLiquidNotice_FRAMEWORKS = UIKit Foundation UserNotifications QuartzCore
LengLengLiquidNotice_RESOURCE_DIRS = Resources
LengLengLiquidNotice_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable
LengLengLiquidNotice_PRIVATE_FRAMEWORKS =
LengLengLiquidNotice_EXTRA_FRAMEWORKS =

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = LengLengLiquidNoticePrefs
LengLengLiquidNoticePrefs_FILES = LLNRootListController.m
LengLengLiquidNoticePrefs_FRAMEWORKS = UIKit Foundation
LengLengLiquidNoticePrefs_PRIVATE_FRAMEWORKS = Preferences
LengLengLiquidNoticePrefs_INSTALL_PATH = /Library/PreferenceBundles
LengLengLiquidNoticePrefs_RESOURCE_DIRS = PrefsResources

include $(THEOS_MAKE_PATH)/bundle.mk

after-stage::
	@mkdir -p "$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences"
	@cp "$(THEOS_PROJECT_DIR)/Resources/PreferenceLoader/Preferences/LengLengLiquidNotice.plist" "$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LengLengLiquidNotice.plist"

include $(THEOS_MAKE_PATH)/aggregate.mk
