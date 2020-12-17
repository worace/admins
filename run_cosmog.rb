require './target'
require 'coque'
require 'json'

# e.g. '/storage/data/cosmogony/north-america.jsonl'
cosmog_file = ARGV[0]
region = File.basename(cosmog_file, ".*")
gj_file = "./output/#{region}.geojsonseq"

pv = Coque['pv']

to_geojson = Coque.rb do |line|
  row = JSON.parse(line)
  geom = row['geometry']
  row.delete('geometry')
  gj = {"type": "Feature", "properties": row, "geometry": geom}
  puts gj.to_json
end

simplify = Coque['geoq', 'simplify', '--to-coord-count', 2000, 0.000001]
coord_count = Coque['geoq', 'measure', 'coord-count', '--geojson']

target gj_file do |f|
  Coque['cat', cosmog_file]
    .pipe(pv)
    .pipe(to_geojson)
    .pipe(simplify)
    .pipe(coord_count)
    .out(gj_file)
    .run!
end

levels = [2,3,4]
COORD_LIMIT = 2000

levels.each do |level|
  target "./output/#{region}_level_#{level}.geojsonseq" do |target|
    File.open(target, "w") do |f|
      File.readlines(gj_file).each do |line|
        row = JSON.parse(line)
        if row['properties']['admin_level'] != level
          next
        end

        if row['properties']['coord_count'] <= COORD_LIMIT
          row['properties'].delete('center_tags')
          row['properties'].delete('international_labels')
          row['properties'].delete('tags')
          f.puts(row.to_json)
        else
          name = row['properties']['name']
          id = row['properties']['osm_id']
          count = row['properties']['coord_count']
          STDERR.puts("Relation #{name} (#{id}) is over 2k coord limit at #{count}")
        end
      end
    end
  end
end
