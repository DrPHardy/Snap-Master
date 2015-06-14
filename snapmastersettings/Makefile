include theos/makefiles/common.mk

BUNDLE_NAME = SnapMasterSettings
SnapMasterSettings_FILES = SnapMasterSettings.mm
SnapMasterSettings_INSTALL_PATH = /Library/PreferenceBundles
SnapMasterSettings_FRAMEWORKS = UIKit
SnapMasterSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SnapMasterSettings.plist$(ECHO_END)
