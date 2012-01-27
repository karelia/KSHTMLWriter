echo Testing Mac

base=`dirname $0`
config="-configuration Debug"
sdkMac="macosx"
targetMac="KSHTMLWriterWebkitTestShellTests"

# build the framework

xcodebuild -target "$targetMac" $config -sdk "$sdkMac" clean build | "${base}/ocunit2junit.rb"