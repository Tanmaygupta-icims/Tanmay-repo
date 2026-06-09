view: flai_date_controls {
  # ----------------------------------------------------------------------
  # Reusable date / time-range controls for FLAI explores.
  #
  # Drop this view into any explore (no join needed -- it has no
  # sql_table_name; all fields are parameter-driven) and reference
  # ${flai_date_controls.anchor_*} from filtered measures or
  # custom dimensions.
  #
  # Usage in an explore:
  #   join: flai_date_controls { relationship: one_to_one sql: ;; }
  #
  # The user picks ONE anchor date + an optional custom range. Derived
  # fields then expose the matching week / month / quarter / year so a
  # single date selection cascades to all granularities.
  # ----------------------------------------------------------------------
  derived_table: {
    sql: select 1 as _dummy ;;
  }

  # ===== Anchor date ====================================================
  parameter: anchor_date {
    label: "Anchor Date"
    type: date
    description: "Pick any date; the Anchor Week/Month/Quarter/Year fields will reflect the bucket containing this date."
  }

  dimension: anchor_date_value {
    label: "Anchor Date"
    type: date
    sql: {% date_start anchor_date %} ;;
  }

  dimension: anchor_week {
    label: "Anchor Week (Mon)"
    type: date
    sql: date_trunc('week', {% date_start anchor_date %}::date) ;;
  }

  dimension: anchor_month {
    label: "Anchor Month"
    type: date
    sql: date_trunc('month', {% date_start anchor_date %}::date) ;;
  }

  dimension: anchor_quarter {
    label: "Anchor Quarter"
    type: date
    sql: date_trunc('quarter', {% date_start anchor_date %}::date) ;;
  }

  dimension: anchor_year {
    label: "Anchor Year"
    type: number
    sql: date_part('year', {% date_start anchor_date %}::date) ;;
  }

  # ===== Custom date / time range ======================================
  # Use this when a campaign ran for an arbitrary window (e.g. a
  # promotion that started 2026-03-14 09:00 UTC and ended 2026-03-21
  # 17:30 UTC). Reference these in `filters:` on measures, or in a
  # `sql_always_where:` on the explore.
  parameter: range_start_at {
    label: "Custom Range Start"
    type: date_time
    description: "Inclusive lower bound of a custom date/time window (e.g. campaign start)."
  }

  parameter: range_end_at {
    label: "Custom Range End"
    type: date_time
    description: "Exclusive upper bound of a custom date/time window (e.g. campaign end)."
  }

  dimension: range_start_value {
    hidden: yes
    type: date_time
    sql: {% date_start range_start_at %} ;;
  }

  dimension: range_end_value {
    hidden: yes
    type: date_time
    sql: {% date_start range_end_at %} ;;
  }

  # ===== Granularity switch ============================================
  # Wire `dynamic_<event>_date` into reports to let viewers flip the
  # report time axis without rebuilding the look.
  parameter: granularity {
    label: "Date Granularity"
    type: unquoted
    default_value: "day"
    allowed_value: { label: "Daily"     value: "day" }
    allowed_value: { label: "Weekly"    value: "week" }
    allowed_value: { label: "Monthly"   value: "month" }
    allowed_value: { label: "Quarterly" value: "quarter" }
    allowed_value: { label: "Annually"  value: "year" }
  }
}
