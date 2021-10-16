require './target'
require 'coque'
require 'json'

# e.g. '/storage/data/cosmogony/north-america.jsonl'
# e.g. 'central-america', 'africa', 'etc'
region = ARGV[0]
# cosmog_file = ARGV[0]

source_pbf = "/storage/data/osm/#{region}-latest.osm.pbf"
cosmog_file = "/storage/data/cosmogony/#{region}.jsonl"
output_dir = '/storage/data/cosmogony/gen'


target cosmog_file do |f|
  Coque['cosmogony', 'generate',
        '-i', source_pbf,
        '-o', cosmog_file]
    .out(STDOUT).err(STDERR).run!
end

pv = Coque['pv']

to_geojson = Coque.rb do |line|
  row = JSON.parse(line)
  geom = row['geometry']
  row.delete('geometry')
  gj = {"type": "Feature", "properties": row, "geometry": geom}
  puts gj.to_json
end

simplify = Coque['geoq', 'simplify', '--to-coord-count', 2000, 0.00000001]
coord_count = Coque['geoq', 'measure', 'coord-count', '--geojson']

gj_file = File.join(output_dir, "#{region}.geojsonseq")
target gj_file do |f|
  Coque['cat', cosmog_file]
    .pipe(pv)
    .pipe(to_geojson)
    .pipe(simplify)
    .pipe(coord_count)
    .out(gj_file)
    .run!
end

levels = ['country', 'state', 'city']
COORD_LIMIT = 2000

def format_and_output_row(row, file)
  if row['properties']['coord_count'] <= COORD_LIMIT
    row['properties'].delete('center_tags')
    row['properties'].delete('international_labels')
    row['properties']['tags'].each do |k,v|
      if k.include?("ISO3166")
        row['properties'][k] = v
      end
    end
    row['properties'].delete('tags')
    file.puts(row.to_json)
  else
    name = row['properties']['name']
    id = row['properties']['osm_id']
    count = row['properties']['coord_count']
    STDERR.puts("Relation #{name} (#{id}) is over 2k coord limit at #{count}")
  end
end

levels.each do |level|
  target File.join(output_dir, "#{region}_#{level}.geojsonseq") do |target|
    generated_target = File.join(output_dir, "#{region}_#{level}_generated.geojsonseq")
    File.open(target, "w") do |f|
      File.open(generated_target, "w") do |generated_f|
        File.readlines(gj_file).map do |line|
          JSON.parse(line)
        end.select do |row|
          row['properties']['zone_type'] == level
        end.each do |row|
          if row['properties']['is_generated']
            puts("got generated row, writing to #{generated_f}")
            format_and_output_row(row, generated_f)
          else
            format_and_output_row(row, f)
          end
        end
      end
    end
  end
end
