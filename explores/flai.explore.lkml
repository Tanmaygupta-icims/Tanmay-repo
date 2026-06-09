include: "/flai/standard/fct_flai_application.view.lkml"
include: "/flai/standard/fct_flai_conversation.view.lkml"
include: "/flai/standard/dim_flai_person.view.lkml"
include: "/flai/standard/dim_date.view.lkml"
include: "/flai/standard/flai_date_controls.view.lkml"

explore: fct_flai_application {
  label: "FLAI Application"

  # Cross-join: parameters-only view, no key.
  join: flai_date_controls {
    relationship: one_to_one
    type: cross
    sql_on: 1=1 ;;
  }

  join: dim_flai_person {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fct_flai_application.person_id} = ${dim_flai_person.person_id} ;;
  }

  join: applied_dim_date {
    from: dim_date
    view_label: "Applied Date"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fct_flai_application.applied_date_key} = ${applied_dim_date.date_day} ;;
  }

  join: hired_dim_date {
    from: dim_date
    view_label: "Hired Date"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fct_flai_application.hired_date_key} = ${hired_dim_date.date_day} ;;
  }
}

explore: fct_flai_conversation {
  label: "FLAI Conversation"

  join: flai_date_controls {
    relationship: one_to_one
    type: cross
    sql_on: 1=1 ;;
  }

  join: dim_flai_person {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fct_flai_conversation.person_id} = ${dim_flai_person.person_id} ;;
  }

  join: started_dim_date {
    from: dim_date
    view_label: "Started Date"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fct_flai_conversation.started_date_key} = ${started_dim_date.date_day} ;;
  }
}
