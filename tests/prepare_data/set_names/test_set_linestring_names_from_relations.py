from osmnames.prepare_data.set_names import set_linestring_names_from_relations


def test_name_is_set_if_linestring_is_relation_member_with_role_street(session, tables):
    session.add(tables.osm_linestring(id=1111, osm_id=1111, name=""))
    session.add(tables.osm_relation(osm_id=-9999, name="Oberfeldring"))
    session.add(tables.osm_relation_member(osm_id=-9999, member_id=1111, role="street"))

    session.commit()

    set_linestring_names_from_relations()

    assert session.query(tables.osm_linestring).get(
        1111).name == "Oberfeldring"


def test_name_is_not_set_if_relation_name_is_empty(session, tables):
    session.add(tables.osm_linestring(id=1111, osm_id=1111, name="Hauptstrasse"))
    session.add(tables.osm_relation(osm_id=-9999, name=""))
    session.add(tables.osm_relation_member(osm_id=-9999, member_id=1111, role="street"))

    session.commit()

    set_linestring_names_from_relations()

    assert session.query(tables.osm_linestring).get(
        1111).name == "Hauptstrasse"
