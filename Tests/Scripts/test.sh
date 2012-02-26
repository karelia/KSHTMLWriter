echo Testing Mac

base=`dirname $0`
common="$base/../ECUnitTests/Scripts/"
source "$common/test-common.sh"

# build & run the tests
xcodebuild -target "KSHTMLWriterTests" -configuration $testConfig -sdk "$testSDKMac" $testOptions | "$common/$testConvertOutput"
