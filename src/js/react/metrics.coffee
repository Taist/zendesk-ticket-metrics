React = require 'react'

{ div, header, section, span, h3 } = React.DOM

ZendeskTicketMetrics = React.createFactory React.createClass
  render: ->
    div { className: 'ember-view box apps_ticket_sidebar app_view' },
      header {},
        h3 {}, 'Ticket metrics'
      section {},
        div {}, 'Put metrics here ' + @props.ticketId

module.exports = ZendeskTicketMetrics
