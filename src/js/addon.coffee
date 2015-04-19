app = require './app'

Q = require 'q'
React = require 'react'

reactComponent = require './react/metrics'

formatMinutesToHM = require './helpers/formatMinutesToHM'

render = (data, workspaceId) ->
  if app.reactTicketMetricsContainers[workspaceId]?
    React.render reactComponent( data ), app.reactTicketMetricsContainers[workspaceId]

getTicketMetrics = (ticketId) ->
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
          if elem #APPS container can be invisible on start
            parent = elem.parentNode
            parent.insertBefore app.reactTicketMetricsContainers[workspaceId], elem.nextSibling

          getTicketMetrics(ticketId, workspaceId)
          .then (response) ->
            render response.ticket_metric or { ticket_id: ticketId } , workspaceId

      if app.reactTicketMetricsContainers[workspaceId]
        unless app.reactTicketMetricsContainers[workspaceId]?.previousSibling?.className.match 'action_buttons'
          elem = workspace[0].querySelector('.ember-view.apps.is_active .action_buttons')
          if elem #APPS container can be invisible on start
            parent = elem.parentNode
            parent.insertBefore app.reactTicketMetricsContainers[workspaceId], elem.nextSibling

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    DOMObserver = require './helpers/domObserver'
    app.observer = new DOMObserver()

    if location.href.match /\.zendesk\.com\/.+\/(tickets|filters)\/(\d+)/

      setInterval waitForTicket, 200

      app.observer.waitElement '.ember-view.apps.is_active .action_buttons', (elem) ->
        workspace = $(elem).parents('.ember-view.workspace:first')
        workspaceId = workspace.attr 'id'

        unless app.reactTicketMetricsContainers[workspaceId]
          container = document.createElement 'div'
          container.className = 'reactContainer'
          app.reactTicketMetricsContainers[workspaceId] = container

          currentTicketId = null

      app.observer.waitElement '.filter-grid-list .filter_tickets tr', (bodyRow) ->
        rightPanel = $(bodyRow).parents('.pane.right.section')[0]
        panelName = rightPanel.querySelector('header.play h1')?.innerText

        unless panelName is 'Recently solved tickets'
          timer = null

        if panelName is 'Recently solved tickets'
          subjectColumn = bodyRow.querySelector '.subject'

          if subjectColumn

            tagName = subjectColumn.tagName
            if tagName.match /td/i

              td = document.createElement 'td'
              td.className = 'waittime'

              ticketId = subjectColumn.querySelector('a').href.match(/\/(\d+)$/)?[1]

              getTicketMetrics(ticketId)
              .then (response) ->
                waitTime = response?.ticket_metric?.requester_wait_time_in_minutes
                td.innerHTML = formatMinutesToHM( waitTime.calendar or 0 )

                waitTimeHeaders = rightPanel.querySelectorAll "th[data-column-id=waittime]"

                unless waitTimeHeaders.length
                  headSubjects = rightPanel.querySelectorAll("th[data-column-id=subject]")
                  Array.prototype.forEach.call headSubjects, (column) ->
                    headRow = column.parentNode
                    th = document.createElement 'th'
                    th.innerHTML = 'Wait time'
                    th.dataset['columnId'] = 'waittime'
                    lastColumn = headRow.querySelector '.trailing'
                    lastColumn.parentNode.insertBefore th, lastColumn

                columns = bodyRow.querySelectorAll 'td'
                Array.prototype.forEach.call columns, (column) ->
                  headers = rightPanel.querySelectorAll "th[data-column-id='#{column.className}']"
                  Array.prototype.forEach.call headers, (columnHeader) ->
                    width = column.offsetWidth
                    columnHeader.setAttribute 'style', "widht: #{width}px; min-width: #{width}px;"

                lastColumn = bodyRow.querySelector '.trailing'
                lastColumn.parentNode.insertBefore td, lastColumn

module.exports = addonEntry
