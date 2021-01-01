require './target'
require 'coque'
require 'json'

STORAGE_DIR = '/storage/data/osm'

files = [
  'central-america-latest.osm.pbf',
  'north-america-latest.osm.pbf',
  'south-america-latest.osm.pbf',
  'africa-latest.osm.pbf',
  'asia-latest.osm.pbf',
  'australia-oceania-latest.osm.pbf',
  'europe-latest.osm.pbf'
]

files.map do |f|
  Thread.new do
    target File.join(STORAGE_DIR, f) do |target|
      url = "https://download.geofabrik.de/#{f}"
      Coque['wget', url, "-O", target].out(STDOUT).err(STDERR).run!
    end
  end
end.map(&:join)
