echo Testing Mac

base=`dirname $0`
config="-configuration Debug"
sdkMac="macosx"

# build & run the simple tests
xcodebuild -target "KSHTMLWriterTests" $config -sdk "$sdkMac" clean build | "${base}/ocunit2junit.rb"

# build & run the webkit tests
xcodebuild -target "KSHTMLWriterWebkitTestShellTests" $config -sdk "$sdkMac" clean build | "${base}/ocunit2junit.rb"