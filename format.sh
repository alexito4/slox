if [ -z $SRCROOT ]; then SRCROOT="."; fi
"${SRCROOT}/swiftformat" "${SRCROOT}/Sources/" --disable "unusedArguments,hoistPatternLet,redundantReturn,redundantRawValues,numberFormatting"