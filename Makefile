export ARCHS = armv7 arm64
export TARGET = iphone:clang:8.1:8.1

include theos/makefiles/common.mk

TWEAK_NAME = SnapMaster
SnapMaster_FILES = Tweak.xm
SnapMaster_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = com.drp.snapmaster
com.drp.snapmaster_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS)/makefiles/bundle.mk

after-install::
	install.exec "killall -9 Snapchat"

SUBPROJECTS += snapmastersettings
include $(THEOS_MAKE_PATH)/aggregate.mk
