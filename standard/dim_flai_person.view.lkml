view: dim_flai_person {
  sql_table_name: "snowplow"."marts"."dim_flai_person" ;;
  label: "FLAI Person"
  view_label: "FLAI Person"

  dimension: person_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.person_id ;;
  }
  dimension: tenant_id { type: string sql: ${TABLE}.tenant_id ;; }
  dimension: customer_id { type: number sql: ${TABLE}.customer_id ;; }
  dimension: full_name { type: string sql: ${TABLE}.full_name ;; }
  dimension: first_name { type: string sql: ${TABLE}.first_name ;; }
  dimension: last_name { type: string sql: ${TABLE}.last_name ;; }
  dimension: primary_email { type: string sql: ${TABLE}.primary_email ;; }
  dimension: primary_phone { type: string sql: ${TABLE}.primary_phone ;; }
  dimension: first_seen_source { type: string sql: ${TABLE}.first_seen_source ;; }
  dimension: ats_linked { type: yesno sql: ${TABLE}.ats_linked ;; }
  dimension: is_visitor { type: yesno sql: ${TABLE}.is_visitor ;; }

  dimension_group: first_seen {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.first_seen_at ;;
    convert_tz: no
  }
  dimension_group: last_modified {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.last_modified_at ;;
    convert_tz: no
  }

  measure: count {
    type: count_distinct
    sql: ${person_id} ;;
  }
}
