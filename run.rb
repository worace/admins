# Run Osmium L2 output
# Extract ISO matches
# Iteratively simplify
require 'fileutils'
require 'coque'

PLANET_PBF = '/storage/data/osm/planet-latest.osm.pbf'

def export_admin_level(level, output)
  tempfile = "/tmp/filtered_admin_level_#{level}.pbf"
  Coque['osmium', 'tags-filter', '-o', tempfile,
        '--overwrite', PLANET_PBF, "wr/admin_level=#{level}"]
    .out(STDOUT).err(STDERR)
    .run!
  cmd = Coque['osmium', 'export', '-i', 'flex_mem', '-c', 'osmium_polygon_config.json',
        '--add-unique-id=type_id', '--geometry-types=polygon', '-f', 'geojsonseq',
        '-x', 'print_record_separator=false', '--verbose', tempfile]
  puts cmd
  cmd.out(output).err(STDERR)
    .run!
end

target './output' do
  FileUtils.mkdir('output')
end

target './output/admin_2.geojsonseq' do |f|
  export_admin_level(2, f)
end
