view: fct_flai_application {
  sql_table_name: "snowplow"."marts"."fct_flai_application" ;;
  label: "FLAI Application"
  view_label: "FLAI Application"

  # ---------- keys / FKs ----------
  dimension: application_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.application_id ;;
  }

  dimension: person_id {
    type: string
    hidden: yes
    sql: ${TABLE}.person_id ;;
  }

  dimension: job_id {
    type: string
    sql: ${TABLE}.job_id ;;
    description: "MO `mo_campaigns_jobopening.external_id` -- external requisition id."
  }

  # ---------- Jira: Client ----------
  dimension: tenant_id {
    type: string
    sql: ${TABLE}.tenant_id ;;
  }
  dimension: customer_id {
    type: number
    sql: ${TABLE}.customer_id ;;
  }
  dimension: client_code {
    type: string
    sql: ${TABLE}.client_code ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}.customer_name ;;
  }
  dimension: tc_tenant_slug {
    type: string
    sql: ${TABLE}.tc_tenant_slug ;;
  }

  # ---------- Jira: Job / Position ----------
  dimension: job_title { type: string sql: ${TABLE}.job_title ;; }
  dimension: job_location_name { type: string sql: ${TABLE}.job_location_name ;; }
  dimension: position_type { type: string sql: ${TABLE}.position_type ;; }
  dimension: position_category { type: string sql: ${TABLE}.position_category ;; }

  # ---------- Jira: Source ----------
  dimension: source { type: string sql: ${TABLE}.source ;; }
  dimension: source_name { type: string sql: ${TABLE}.source_name ;; }
  dimension: source_channel { type: string sql: ${TABLE}.source_channel ;; }

  # ---------- Lifecycle / flags ----------
  dimension: lifecycle_label { type: string sql: ${TABLE}.lifecycle_label ;; }
  dimension: flai_attributed { type: yesno sql: ${TABLE}.flai_attributed ;; }
  dimension: ats_linked { type: yesno sql: ${TABLE}.ats_linked ;; }
  dimension: is_started { type: yesno sql: ${TABLE}.is_started ;; hidden: yes }
  dimension: is_completed { type: yesno sql: ${TABLE}.is_completed ;; hidden: yes }
  dimension: is_hired { type: yesno sql: ${TABLE}.is_hired ;; hidden: yes }
  dimension: is_interview_scheduled { type: yesno sql: ${TABLE}.is_interview_scheduled ;; hidden: yes }
  dimension: apli_score { type: number sql: ${TABLE}.apli_score ;; }

  # ---------- Dates (raw timestamp + ATS-style ::date) ----------
  dimension_group: applied {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.applied_at ;;
    convert_tz: no
    description: "Application start (FLAI conversation start when available)."
  }
  dimension_group: application_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.application_completed_at ;;
    convert_tz: no
  }
  dimension_group: hired {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.hired_at ;;
    convert_tz: no
  }

  # `*_date` columns are the ATS-style materialised date keys used for
  # joining `dim_date` when calendar-spine reports are needed.
  dimension: applied_date_key { hidden: yes type: date sql: ${TABLE}.applied_date ;; }
  dimension: hired_date_key   { hidden: yes type: date sql: ${TABLE}.hired_date ;;   }

  # Dynamic axis driven by `flai_date_controls.granularity`. Drop into
  # any look in place of a static `applied_*` field; the report's time
  # axis follows the granularity picker.
  dimension: dynamic_applied_date {
    label: "Applied (Dynamic)"
    sql:
      {% if flai_date_controls.granularity._parameter_value == 'week' %}    ${applied_week}
      {% elsif flai_date_controls.granularity._parameter_value == 'month' %}   ${applied_month}
      {% elsif flai_date_controls.granularity._parameter_value == 'quarter' %} ${applied_quarter}
      {% elsif flai_date_controls.granularity._parameter_value == 'year' %}    ${applied_year}
      {% else %}                                                               ${applied_date}
      {% endif %} ;;
  }

  # Filter helper for ad-hoc campaign windows. Returns `yes` when the
  # application's `applied_at` falls inside the user-picked
  # `flai_date_controls.range_start_at` .. `range_end_at`.
  dimension: applied_in_custom_range {
    type: yesno
    sql:
      ${TABLE}.applied_at >= coalesce(${flai_date_controls.range_start_value}, '1900-01-01'::timestamp)
      and ${TABLE}.applied_at <  coalesce(${flai_date_controls.range_end_value},   '9999-12-31'::timestamp) ;;
  }

  # ---------- Measures (fact-grain aggregations, per PR-review rule) ----------
  measure: application_starts {
    label: "Application Starts"
    type: count_distinct
    sql: ${application_id} ;;
    filters: [is_started: "yes"]
    description: "Distinct applications where the candidate started the flow."
  }
  measure: applications_completed {
    label: "Applications Completed"
    type: count_distinct
    sql: ${application_id} ;;
    filters: [is_completed: "yes"]
  }
  measure: hires {
    label: "Hires"
    type: count_distinct
    sql: ${application_id} ;;
    filters: [is_hired: "yes"]
  }
  measure: interviews_scheduled {
    label: "Interviews Scheduled"
    type: count_distinct
    sql: ${application_id} ;;
    filters: [is_interview_scheduled: "yes"]
  }
  measure: flai_attributed_applications {
    label: "FLAI-Attributed Applications"
    type: count_distinct
    sql: ${application_id} ;;
    filters: [flai_attributed: "yes"]
  }
  measure: unique_applicants {
    label: "Unique Applicants"
    type: count_distinct
    sql: ${person_id} ;;
  }
}
