#!/bin/sh
set -e

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

case "${TARGETED_DEVICE_FAMILY}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

realpath() {
  DIRECTORY="$(cd "${1%/*}" && pwd)"
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\""
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "$RESOURCE_PATH")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH"
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_chrome@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_chrome@2x~ipad.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_dolphin@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_dolphin@2x~ipad.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_link@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_link@2x~ipad.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_opera@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_opera@2x~ipad.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_safari@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_safari@2x~ipad.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_action.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_action@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_action@3x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_backward.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_backward@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_backward@3x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_forward.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_forward@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_forward@3x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_reload.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_reload@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_reload@3x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_stop.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_stop@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_stop@3x.png"
  install_resource "DZNWebViewController/Source/Resources/de.lproj"
  install_resource "DZNWebViewController/Source/Resources/en.lproj"
  install_resource "DZNWebViewController/Source/Resources/es.lproj"
  install_resource "GoogleAuthUtilities/Frameworks/frameworks/GoogleAuthUtilities.framework/Resources/GTMOAuth2ViewTouch.xib"
  install_resource "GoogleSignIn/Resources/GoogleSignIn.bundle"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-down.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-down@2x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-down@3x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-left.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-left@2x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-left@3x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-right.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-right@2x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-right@3x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-top.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-top@2x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-top@3x.png"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_chrome@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_chrome@2x~ipad.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_dolphin@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_dolphin@2x~ipad.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_link@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_link@2x~ipad.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_opera@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_opera@2x~ipad.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_safari@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_activity_safari@2x~ipad.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_action.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_action@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_action@3x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_backward.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_backward@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_backward@3x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_forward.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_forward@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_forward@3x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_reload.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_reload@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_reload@3x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_stop.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_stop@2x.png"
  install_resource "DZNWebViewController/Source/Resources/dzn_icn_toolbar_stop@3x.png"
  install_resource "DZNWebViewController/Source/Resources/de.lproj"
  install_resource "DZNWebViewController/Source/Resources/en.lproj"
  install_resource "DZNWebViewController/Source/Resources/es.lproj"
  install_resource "GoogleAuthUtilities/Frameworks/frameworks/GoogleAuthUtilities.framework/Resources/GTMOAuth2ViewTouch.xib"
  install_resource "GoogleSignIn/Resources/GoogleSignIn.bundle"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-down.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-down@2x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-down@3x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-left.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-left@2x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-left@3x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-right.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-right@2x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-right@3x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-top.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-top@2x.png"
  install_resource "MPCoachMarks/MPCoachMarks/arrows/arrow-top@3x.png"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
