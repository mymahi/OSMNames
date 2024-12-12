CREATE VIEW geonames_view AS
  SELECT * FROM final_polygons
  UNION ALL
  SELECT * FROM final_points
  UNION ALL
  SELECT * FROM final_linestrings
  UNION ALL
  SELECT * FROM final_merged_linestrings;
