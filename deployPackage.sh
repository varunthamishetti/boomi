#!/bin/bash

# Source the common.sh file
if [ -f "bin/common.sh" ]; then
    source bin/common.sh
else
    echo "Error: bin/common.sh not found. Make sure it exists in the correct path."
    exit 1
fi

# Define mandatory arguments
ARGUMENTS=(env packageVersion notes listenerStatus)
OPT_ARGUMENTS=(componentId processName componentVersion extractComponentXmlFolder tag componentType)

# Call the inputs function
inputs "$@"
if [ "$?" -gt "0" ]; then
    exit 255
fi

# Check if extractComponentXmlFolder is provided
if [ ! -z "${extractComponentXmlFolder}" ]; then
    folder="${WORKSPACE}/${extractComponentXmlFolder}"
    rm -rf ${folder}
    unset extensionJson
    saveExtractComponentXmlFolder="${extractComponentXmlFolder}"
fi

saveNotes="${notes}"
saveTag="${tag}"

# Source the createSinglePackage.sh script
source bin/createSinglePackage.sh componentId=${componentId} processName="${processName}" componentType="${componentType}" componentVersion="${componentVersion}" packageVersion="$packageVersion" notes="$notes" extractComponentXmlFolder="${extractComponentXmlFolder}"
notes="${saveNotes}"

# Source the queryEnvironment.sh script
source bin/queryEnvironment.sh env="$env" classification="*"
saveEnvId=${envId}

# Source the createDeployedPackage.sh script
source bin/createDeployedPackage.sh envId=${envId} listenerStatus="${listenerStatus}" packageId=$packageId notes="$notes"

# Call handleXmlComponents function
handleXmlComponents "${saveExtractComponentXmlFolder}" "${saveTag}" "${saveNotes}"

# Check for errors
if [ "$ERROR" -gt "0" ]; then
    exit 255
fi

# Export envId
export envId=${saveEnvId}

# Call the clean function
clean
