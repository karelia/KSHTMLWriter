echo Testing Mac

base=`dirname $0`
config="-configuration Debug"
sdkMac="macosx"
options="clean build TEST_AFTER_BUILD=YES"

CONVERT_OUTPUT="${base}/../../KSWriter/Tests/Scripts/ocunit2junit.rb"

# build & run the simple tests
xcodebuild -target "KSHTMLWriterTests" $config -sdk "$sdkMac" $options | "$CONVERT_OUTPUT"

# build & run the webkit tests
xcodebuild -target "KSHTMLWriterWebkitTestShellTests" $config -sdk "$sdkMac" $options | "$CONVERT_OUTPUT" 