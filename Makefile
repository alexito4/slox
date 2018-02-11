
fetch: 
	swift package --enable-prefetching update

build:	
	swift build -Xswiftc -target -Xswiftc x86_64-apple-macosx10.11

astgen: build
	./.build/debug/GenerateAst ./Sources/LoxCore/

format:
	sh format.sh

test: build
	./tools/test.py chap13_inheritance

clean:
	rm -rf .build

xcode: fetch
	swift package generate-xcodeproj --xcconfig-overrides ./Config.xcconfig

edit: xcode
	open ./Genesis.xcodeproj