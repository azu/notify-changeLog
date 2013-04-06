test:
	script/cibuild Tests
	# xcodebuild -workspace notify-changeLog.xcworkspace -scheme Tests -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO TEST_AFTER_BUILD=YES clean build