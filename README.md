## Admin Region Exporting

```
./export_level.sh /storage/data/osm/planet-latest.osm.pbf 2 > /storage/data/osm/admin_2.geojsonseq
```

Cosmog

```
cosmogony generate \
  -i /storage/data/osm/north-america-latest.osm.pbf \
  -o /storage/data/cosmogony/north-america.jsonl

cosmogony generate \
  -i /storage/data/osm/south-america-latest.osm.pbf \
  -o /storage/data/cosmogony/south-america.jsonl
```
