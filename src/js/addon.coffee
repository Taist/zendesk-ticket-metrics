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

    if true #location.href.match /\.zendesk\.com\/.+\/(tickets|filters)\/(\d+)/

      setInterval waitForTicket, 200

      app.observer.waitElement '.ember-view.apps.is_active .action_buttons', (elem) ->
        app.log "observer on ticket page #{location.href}"
        workspace = $(elem).parents('.ember-view.workspace:first')
        workspaceId = workspace.attr 'id'

        unless app.reactTicketMetricsContainers[workspaceId]
          container = document.createElement 'div'
          container.className = 'reactContainer'
          app.reactTicketMetricsContainers[workspaceId] = container

          currentTicketId = null

      app.observer.waitElement '.filter-grid-list .filter_tickets tr.solved', (bodyRow) ->
        rightPanel = $(bodyRow).parents('.pane.right.section')[0]
        panelName = rightPanel.querySelector('header.play h1')?.innerText

        if panelName is 'Recently solved tickets'
          # app.log "panel name is *#{panelName}*"

          subjectColumn = bodyRow.querySelector '.subject'

          if subjectColumn
            # app.log 'subject column found'

            tagName = subjectColumn.tagName
            if tagName.match /td/i
              # app.log 'tagname matched'

              td = document.createElement 'td'
              td.className = 'waittime'

              ticketId = subjectColumn.querySelector('a').href.match(/\/(\d+)$/)?[1]

              getTicketMetrics(ticketId)
              .then (response) ->
                app.log "received metrics for #{ticketId}"
                waitTime = response?.ticket_metric?.requester_wait_time_in_minutes
                td.innerHTML = formatMinutesToHM( waitTime.calendar or 0 )

                waitTimeHeaders = rightPanel.querySelectorAll "th[data-column-id=waittime]"

                unless waitTimeHeaders.length
                  # app.log 'wait time header not found'
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

              .fail (error) ->
                app.log JSON.stringify error

module.exports = addonEntry
