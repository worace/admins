#!/usr/bin/env bash

set -euo pipefail

INPUT_PBF=$1
LEVEL=$2
FILTERED_FILE=/tmp/filtered_admin_level_$LEVEL.pbf
# OUTPUT_FILE=$2

osmium tags-filter \
       -o $FILTERED_FILE \
       --overwrite \
       $INPUT_PBF \
       wr/admin_level=$LEVEL

osmium export \
       -i flex_mem \
       -c osmium_polygon_config.json \
       --add-unique-id=type_id \
       --geometry-types=polygon \
       -f geojsonseq \
       -x print_record_separator=false \
       --verbose \
       $FILTERED_FILE
