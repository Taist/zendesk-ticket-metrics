_responseHandlers = []
_listening = false

module.exports =
  onRequestFinish: (responseHandler) ->
    _responseHandlers.push responseHandler
    if not _listening
      _listenToRequests()

_listenToRequests = ->
  originalSend = XMLHttpRequest.prototype.send
  XMLHttpRequest.prototype.send = ->
    _listenForRequestFinish @
    originalSend.apply @, arguments

_listenForRequestFinish = (request) ->
  originalOnReadyStateChange = request.onreadystatechange
  request.onreadystatechange = ->
    finished = request.readyState is 4
    if finished
      for handler in _responseHandlers
        handler request

    originalOnReadyStateChange?.apply request, arguments
