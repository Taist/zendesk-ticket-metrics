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

    if matches = location.href.match /\/agent\/filters\/(\d+)/

      timer = null

      app.observer.waitElement '.filter-grid-list .filter_tickets tr', (tableRow) ->
        rightPanel = $(tableRow).parents('.pane.right.section')[0]
        panelName = rightPanel.querySelector('header.play h1')?.innerText

        unless panelName is 'Recently solved tickets'
          timer = null

        if panelName is 'Recently solved tickets'
          subjectColumn = tableRow.querySelector '.subject, [data-column-id=subject]'

          if subjectColumn

            tagName = subjectColumn.tagName
            td = document.createElement tagName
            td.style.width = '70px'
            td.style.minWidth = '70px'

            if tagName.match /td/i
              ticketId = subjectColumn.querySelector('a').href.match(/\/(\d)+$/)?[1]
              td.innerHTML = ticketId
              td.className = 'waittime'
            else
              td.innerHTML = 'Wait time'
              td.dataset['columnId'] = 'waittime'

            lastColumn = tableRow.querySelector '.trailing'
            lastColumn.parentNode.insertBefore td, lastColumn

            if tagName.match /td/i

              # app.observer.waitElement 'th[data-column-id]', (columnHeader) ->
              #   console.log 'observer', columnHeader.style
              #   console.log columnHeader
              # , attributes: true

              unless timer
                timer = setTimeout ->
                  columns = tableRow.querySelectorAll 'td'
                  Array.prototype.forEach.call columns, (column) ->
                    headers = rightPanel.querySelectorAll "th[data-column-id=#{column.className}]"
                    Array.prototype.forEach.call headers, (columnHeader) ->
                      width = column.offsetWidth
                      columnHeader.setAttribute 'style', "widht: #{width}px; min-width: #{width}px;"
                      # console.log columnHeader
                      # console.log columnHeader.style
                      # console.log width
                , 0

module.exports = addonEntry
