DROP TABLE IF EXISTS final_merged_linestrings CASCADE;
CREATE UNLOGGED TABLE final_merged_linestrings (
    name varchar,
    alternative_names text,
    osm_type text,
    osm_id varchar,
    class text,
    type text,
    lon numeric,
    lat numeric,
    place_rank integer,
    importance double precision,
    street text,
    city text,
    county text,
    state text,
    country text,
    country_code varchar(2),
    display_name text,
    west numeric,
    south numeric,
    east numeric,
    north numeric,
    wikidata text,
    wikipedia text,
    housenumbers text
);

INSERT INTO final_merged_linestrings(name, alternative_names, osm_type, osm_id, class, type, lon, lat, place_rank, importance, street, city, county, state, country, country_code, display_name, west, south, east, north, wikidata, wikipedia, housenumbers)
SELECT
  name,
  alternative_names,
  'way'::TEXT as osm_type,
  osm_id::VARCHAR AS osm_id,
  class,
  type,
  round(ST_X(ST_PointOnSurface(ST_Transform(geometry, 4326)))::numeric, 5) AS lon,
  round(ST_Y(ST_PointOnSurface(ST_Transform(geometry, 4326)))::numeric, 5) AS lat,
  place_rank,
  get_importance(place_rank, wikipedia, parentInfo.country_code) AS importance,
  CASE WHEN class = 'highway' THEN name ELSE NULL::TEXT END AS street,
  parentInfo.city AS city,
  parentInfo.county AS county,
  parentInfo.state AS state,
  get_country_name(parentInfo.country_code) AS country,
  parentInfo.country_code AS country_code,
  parentInfo.displayName AS display_name,
  round(ST_XMIN(ST_Transform(geometry, 4326))::numeric, 5) AS west,
  round(ST_YMIN(ST_Transform(geometry, 4326))::numeric, 5) AS south,
  round(ST_XMAX(ST_Transform(geometry, 4326))::numeric, 5) AS east,
  round(ST_YMAX(ST_Transform(geometry, 4326))::numeric, 5) AS north,
  NULLIF(wikidata, '') AS wikidata,
  NULLIF(wikipedia, '') AS wikipedia,
  get_housenumbers(osm_id) AS housenumbers
FROM
  osm_merged_linestring,
  determine_class(type) AS class,
  get_parent_info(parent_id, name) as parentInfo
WHERE auto_modulo(osm_id);
