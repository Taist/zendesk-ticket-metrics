app = require './app'

React = require 'react'

reactComponent = require './react/metrics'

render = (data, workspaceId) ->
  if app.reactTicketMetricsContainers[workspaceId]?
    React.render reactComponent( data ), app.reactTicketMetricsContainers[workspaceId]

getTicketMetrics = (ticketId, workspaceId) ->
  $.ajax url: "/api/v2/tickets/#{ticketId}/metrics.json"

currentTicketId = null
waitForTicket = () ->
  if matches = location.href.match /\.zendesk\.com\/.+\/tickets\/(\d+)/
    ticketId = matches[1]
    workspace = $('.ember-view.workspace:visible')
    workspaceId = workspace.attr 'id'

    if workspace?[0]?
      if ticketId isnt currentTicketId
        currentTicketId = ticketId

        if app.reactTicketMetricsContainers[workspaceId]
          elem = workspace[0].querySelector('.ember-view.apps.is_active .action_buttons')
          parent = elem.parentNode
          parent.insertBefore app.reactTicketMetricsContainers[workspaceId], elem.nextSibling

          getTicketMetrics(ticketId, workspaceId)
          .then (response) ->
            render response.ticket_metric or { ticket_id: ticketId } , workspaceId

      unless app.reactTicketMetricsContainers[workspaceId]?.previousSibling?.className.match 'action_buttons'
        elem = workspace[0].querySelector('.ember-view.apps.is_active .action_buttons')
        parent = elem.parentNode
        parent.insertBefore app.reactTicketMetricsContainers[workspaceId], elem.nextSibling

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    DOMObserver = require './helpers/domObserver'
    app.observer = new DOMObserver()

    if matches = location.href.match /\.zendesk\.com\/.+\/tickets\/(\d+)/
      ticketId = matches[1]

      setInterval waitForTicket, 200

      app.observer.waitElement '.ember-view.apps.is_active .action_buttons', (elem) ->
        workspace = $(elem).parents('.ember-view.workspace:first')
        workspaceId = workspace.attr 'id'

        unless app.reactTicketMetricsContainers[workspaceId]
          container = document.createElement 'div'
          container.className = 'reactContainer'
          app.reactTicketMetricsContainers[workspaceId] = container

          currentTicketId = null

module.exports = addonEntry
