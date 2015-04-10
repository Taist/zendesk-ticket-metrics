React = require 'react'

{ div, header, section, span, h3 } = React.DOM

formatMinutesToHM = (minutes) ->
  minutes = 0 unless minutes
  minutes = parseInt minutes, 10

  h = Math.floor minutes/60
  m = ('0' + minutes%60).slice -2
  return "#{h}:#{m}"

formatMinutesVar = (minutesObj) ->
  if minutesObj?.business? and minutesObj?.calendar?
    formatMinutesToHM(minutesObj?.business) + ' / ' + formatMinutesToHM(minutesObj?.calendar)
  else
    'Unknown'

ZendeskTicketMetrics = React.createFactory React.createClass
  render: ->
    div { className: 'ember-view box apps_ticket_sidebar app_view' },
      header {},
        h3 {}, 'Ticket metrics'
      section {},
        div {},
          div { style: display: 'inline-block', width: 200 }, 'Requester wait time'
          div {
            title: 'business hours / calendar hours'
            style:
              display: 'inline-block'
              width: 120
              textAlign: 'right'
          },
            formatMinutesVar @props.requester_wait_time_in_minutes

module.exports = ZendeskTicketMetrics
