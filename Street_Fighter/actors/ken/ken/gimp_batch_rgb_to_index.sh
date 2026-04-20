#!/bin/bash

WORKINGDIR="$( cd -- "$( dirname -- "${BASH_SOURCE}" )" &> /dev/null && pwd )"
cd "$WORKINGDIR"

mkdir -p output
PALETTE="dkpal"

GIMP_CMD=$(command -v gimp-console-3.0 || command -v gimp-3.0 || command -v gimp)

for img in *.png *.gif; do
  echo "Processing $img..."
  OUTPUT_PATH="output/$img"

  $GIMP_CMD -i --batch-interpreter=plug-in-script-fu-eval -b "
    (script-fu-use-v3)
    (let* (
        ;; Load the image
        (image (gimp-file-load RUN-NONINTERACTIVE \"$img\" \"$img\"))
        
        ;; GIMP 3 renamed: gimp-image-get-base-type
        (base-type (gimp-image-get-base-type image))
      )
      ;; Convert to RGB if not already (RGB is 0)
      (if (not (= base-type 0)) (gimp-image-convert-rgb image))
      
      ;; GIMP 3 Indexed Conversion: image, dither, palette-type, num-cols, alpha-dither, remove-unused, palette-name
      (gimp-image-convert-indexed image 0 4 0 #f #f \"$PALETTE\")
      
      ;; Export the image (Export handles the active drawables automatically)
      (gimp-file-export RUN-NONINTERACTIVE image \"$OUTPUT_PATH\")
      
      ;; Clean up
      (gimp-image-delete image)
    )" -b "(gimp-quit 0)"
done

echo "Done!"
