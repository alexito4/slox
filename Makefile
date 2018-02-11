
fetch: 
	swift package --enable-prefetching update

build: fetch	
	swift build -Xswiftc -target -Xswiftc x86_64-apple-macosx10.11

astgen: build
	./.build/debug/GenerateAst ./Sources/LoxCore/

format:
	sh format.sh

test: build
	./tools/test.py chap12_classes

clean:
	rm -rf .build

xcode: fetch
	swift package generate-xcodeproj --xcconfig-overrides ./Config.xcconfig

edit: xcode
	open ./Genesis.xcodeproj