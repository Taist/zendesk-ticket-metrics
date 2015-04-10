app = require './app'

React = require 'react'

reactComponent = require './react/metrics'

render = (data, workspaceId) ->
  if app.reactTicketMetricsContainers[workspaceId]?
    React.render reactComponent( data ), app.reactTicketMetricsContainers[workspaceId]

currentTicketId = null
waitForTicket = () ->
  if matches = location.href.match /\.zendesk\.com\/.+\/tickets\/(\d+)/
    ticketId = matches[1]
    if ticketId isnt currentTicketId
      console.log ticketId
      currentTicketId = ticketId

      workspace = $('.ember-view.workspace:visible')
      workspaceId = workspace.attr 'id'

      if app.reactTicketMetricsContainers[workspaceId]
        elem = workspace[0].querySelector('.ember-view.apps.is_active .action_buttons')
        parent = elem.parentNode
        console.log elem.nextSibling
        parent.insertBefore app.reactTicketMetricsContainers[workspaceId], elem.nextSibling

        render { ticketId }, workspaceId

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
        console.log 'observer'

        workspace = $(elem).parents('.ember-view.workspace:first')
        workspaceId = workspace.attr 'id'

        unless app.reactTicketMetricsContainers[workspaceId]
          container = document.createElement 'div'
          container.className = 'reactContainer'
          app.reactTicketMetricsContainers[workspaceId] = container

          currentTicketId = null
          render { ticketId }, workspaceId

module.exports = addonEntry
