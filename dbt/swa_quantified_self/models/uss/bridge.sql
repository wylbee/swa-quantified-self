{{ dbt_utils.union_relations(relations=[ref("tmp_self_stream_unpacked")]) }}
