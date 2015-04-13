class DOMObserver
  bodyObserver: null
  isActive: no
  observers: {}

  processedOnce: []

  checkForAction: (selector, observer, container) ->
    nodesList = container.querySelectorAll selector
    matchedElems = Array.prototype.slice.call nodesList
    matchedElems.forEach (elem) =>
      if elem and @processedOnce.indexOf(elem) < 0
        @processedOnce.push elem
        observer.action elem

  constructor: ->
    @bodyObserver = new MutationObserver (mutations) =>
      mutations.forEach (mutation) =>
        for selector, observer of @observers
          @checkForAction selector, observer, mutation.target

  activateMainObserver: (config) ->
    unless @isActive
      @isActive = yes
      target = document.querySelector 'body'

      config = { subtree: true, childList: true } unless config

      @bodyObserver.observe target, config

  waitElement: (selector, action, config) ->
    @activateMainObserver config
    observer = { selector, action }
    @observers[selector] = observer
    @checkForAction selector, observer, document.querySelector 'body'

module.exports = DOMObserver
