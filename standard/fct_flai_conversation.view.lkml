view: fct_flai_conversation {
  sql_table_name: "snowplow"."marts"."fct_flai_conversation" ;;
  label: "FLAI Conversation"
  view_label: "FLAI Conversation"

  dimension: conversation_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.conversation_id ;;
  }
  dimension: person_id { type: string sql: ${TABLE}.person_id ;; hidden: yes }
  dimension: tenant_id { type: string sql: ${TABLE}.tenant_id ;; }
  dimension: test_id { type: string sql: ${TABLE}.test_id ;; }
  dimension: language { type: string sql: ${TABLE}.language ;; }
  dimension: is_completed { type: yesno sql: ${TABLE}.is_completed ;; hidden: yes }
  dimension: conversation_score { type: number sql: ${TABLE}.conversation_score ;; }
  dimension: answers_in_conversation_value {
    hidden: yes
    type: number
    sql: ${TABLE}.answers_in_conversation ;;
  }

  dimension_group: started {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.started_at ;;
    convert_tz: no
  }
  dimension_group: ended {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.ended_at ;;
    convert_tz: no
  }
  dimension: started_date_key { hidden: yes type: date sql: ${TABLE}.started_date ;; }

  dimension: dynamic_started_date {
    label: "Started (Dynamic)"
    sql:
      {% if flai_date_controls.granularity._parameter_value == 'week' %}    ${started_week}
      {% elsif flai_date_controls.granularity._parameter_value == 'month' %}   ${started_month}
      {% elsif flai_date_controls.granularity._parameter_value == 'quarter' %} ${started_quarter}
      {% elsif flai_date_controls.granularity._parameter_value == 'year' %}    ${started_year}
      {% else %}                                                               ${started_date}
      {% endif %} ;;
  }

  dimension: started_in_custom_range {
    type: yesno
    sql:
      ${TABLE}.started_at >= coalesce(${flai_date_controls.range_start_value}, '1900-01-01'::timestamp)
      and ${TABLE}.started_at <  coalesce(${flai_date_controls.range_end_value},   '9999-12-31'::timestamp) ;;
  }

  # ---------- Measures ----------
  measure: total_conversations {
    label: "Total Conversations"
    type: count_distinct
    sql: ${conversation_id} ;;
  }
  measure: unique_visitors {
    label: "Unique Visitors"
    type: count_distinct
    sql: ${person_id} ;;
    description: "Distinct people who had at least one FLAI conversation."
  }
  measure: questions_answered {
    label: "Questions Answered"
    type: sum
    sql: ${answers_in_conversation_value} ;;
  }
  measure: completed_conversations {
    label: "Completed Conversations"
    type: count_distinct
    sql: ${conversation_id} ;;
    filters: [is_completed: "yes"]
  }

  # ---------- Repeated Engagement Rate (derived measure) ----------
  # A repeated visitor is one with >= 2 conversations in the selected
  # period. The numerator counts visitor-periods, the denominator counts
  # the same population once, so the rate is independent of the join
  # fanout. Using `count(distinct case ...)` keeps the calculation
  # symmetric-aggregate friendly for Looker.
  measure: repeated_visitors {
    label: "Repeated Visitors"
    type: number
    sql:
      count(distinct case
        when (select count(*) from "snowplow"."marts"."fct_flai_conversation" c2
              where c2.person_id = ${TABLE}.person_id
                and date_trunc('month', c2.started_at)
                  = date_trunc('month', ${TABLE}.started_at)) >= 2
        then ${person_id}
      end) ;;
    description: "People with >= 2 conversations in the same calendar month."
  }
  measure: repeated_engagement_rate_pct {
    label: "Repeated Engagement Rate (%)"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${repeated_visitors} / nullif(${unique_visitors}, 0) ;;
    description: "Repeated Visitors / Unique Visitors for the selected period."
  }
}
