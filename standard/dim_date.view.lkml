view: dim_date {
  sql_table_name: "snowplow"."marts"."dim_date" ;;
  label: "Date"
  view_label: "Date"

  dimension: date_day {
    primary_key: yes
    type: date
    sql: ${TABLE}.date_day ;;
  }
  dimension: calendar_year { type: number sql: ${TABLE}.calendar_year ;; }
  dimension: quarter_of_year { type: number sql: ${TABLE}.quarter_of_year ;; }
  dimension: month_of_year { type: number sql: ${TABLE}.month_of_year ;; }
  dimension: week_of_year { type: number sql: ${TABLE}.week_of_year ;; }
  dimension: day_of_month { type: number sql: ${TABLE}.day_of_month ;; }
  dimension: day_of_week { type: number sql: ${TABLE}.day_of_week ;; }
  dimension: day_of_year { type: number sql: ${TABLE}.day_of_year ;; }
  dimension: week_start_date { type: date sql: ${TABLE}.week_start_date ;; }
  dimension: month_start_date { type: date sql: ${TABLE}.month_start_date ;; }
  dimension: quarter_start_date { type: date sql: ${TABLE}.quarter_start_date ;; }
  dimension: year_start_date { type: date sql: ${TABLE}.year_start_date ;; }
  dimension: year_month { type: string sql: ${TABLE}.year_month ;; }
  dimension: year_quarter { type: string sql: ${TABLE}.year_quarter ;; }
  dimension: month_name { type: string sql: ${TABLE}.month_name ;; }
  dimension: day_name { type: string sql: ${TABLE}.day_name ;; }
  dimension: is_weekend { type: yesno sql: ${TABLE}.is_weekend ;; }
}
