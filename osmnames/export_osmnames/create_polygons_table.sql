DROP TABLE IF EXISTS final_polygons CASCADE;
CREATE UNLOGGED TABLE final_polygons (
    name varchar,
    alternative_names text,
    osm_type text,
    osm_id varchar,
    class text,
    type varchar,
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
    housenumbers varchar
);

INSERT INTO final_polygons(name, alternative_names, osm_type, osm_id, class, type, lon, lat, place_rank, importance, street, city, county, state, country, country_code, display_name, west, south, east, north, wikidata, wikipedia, housenumbers)
SELECT
  name,
  alternative_names,
  CASE WHEN osm_id > 0 THEN 'way' ELSE 'relation' END AS osm_type,
  abs(osm_id)::VARCHAR as osm_id,
  determine_class(type) AS class,
  type,
  round(ST_X(ST_PointOnSurface(ST_Buffer(ST_Transform(geometry, 4326), 0.0)))::numeric::numeric, 5) AS lon,
  round(ST_Y(ST_PointOnSurface(ST_Buffer(ST_Transform(geometry, 4326), 0.0)))::numeric::numeric, 5) AS lat,
  place_rank,
  get_importance(place_rank, wikipedia, parentInfo.country_code) AS importance,
  NULL::TEXT AS street,
  parentInfo.city AS city,
  parentInfo.county AS county,
  parentInfo.state AS state,
  get_country_name(parentInfo.country_code) AS country,
  parentInfo.country_code AS country_code,
  parentInfo.displayName  AS display_name,
  bounding_box[1] AS west,
  bounding_box[2] AS south,
  bounding_box[3] AS east,
  bounding_box[4] AS north,
  NULLIF(wikidata, '') AS wikidata,
  NULLIF(wikipedia, '') AS wikipedia,
  NULL::VARCHAR AS housenumbers
FROM
  osm_polygon,
  get_parent_info(id, '') as parentInfo,
  get_bounding_box(geometry, parentInfo.country_code, admin_level) AS bounding_box
WHERE auto_modulo(abs(osm_id));
