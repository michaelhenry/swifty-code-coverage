#!/bin/sh
OUTPUT_FILE="coverage/lcov.info"
IGNORE_FILENAME_REGEX=".build|Tests|Pods|Carthage|DerivedData"
IS_SPM=false

while :; do
  case $1 in
    --build-path) BUILD_PATH=$2
    shift
    ;;
    --target) TARGET=$2
    shift
    ;;
    --is-spm) IS_SPM=$2
    shift
    ;;
    --ignore-filename-regex) IGNORE_FILENAME_REGEX=$2
    shift
    ;;
    --output) OUTPUT_FILE=$2
    shift
    ;;
    *) break
  esac
  shift
done

if [ -z "$BUILD_PATH" ]; then
  echo "Missing --build-path. Either DerivedData or .build (for spm)"
  exit 1
fi

if [ -z "$TARGET" ]; then
  echo "Missing --target. Either an .app or an .xctest (for spm)"
  exit 1
fi

INSTR_PROFILE=$(find $BUILD_PATH -name "*.profdata")
if [ $IS_SPM = true ]; then
  TARGET_PATH=$(find $BUILD_PATH -name "$TARGET" | tail -n1)
  if [ -f $TARGET_PATH ]; then
    OBJECT_FILE="$TARGET_PATH"
  else
    TARGET=$(echo $TARGET | sed  's/\.[^.]*$//')
    OBJECT_FILE=$(find $BUILD_PATH -name "$TARGET" | tail -n1)
  fi
else
  TARGET=$(echo $TARGET | sed  's/\.[^.]*$//')
  TARGET_PATH=$(find $BUILD_PATH -name "$TARGET.app")
  OBJECT_FILE="$TARGET_PATH/$TARGET"
fi

mkdir -p $(dirname "$OUTPUT_FILE")

LLVM_COV_CMD="llvm-cov"
if [ "$RUNNER_OS" == "macOS" ]; then
  LLVM_COV_CMD="xcrun llvm-cov"
fi

# print to stdout
$LLVM_COV_CMD report \
  "$OBJECT_FILE" \
  --instr-profile=$INSTR_PROFILE \
  --ignore-filename-regex=$IGNORE_FILENAME_REGEX \
  --use-color

# Export to code coverage file
$LLVM_COV_CMD export \
  "$OBJECT_FILE" \
  --instr-profile=$INSTR_PROFILE \
  --ignore-filename-regex=$IGNORE_FILENAME_REGEX \
  --format="lcov" > $OUTPUT_FILE