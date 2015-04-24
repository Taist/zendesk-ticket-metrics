Q = require 'q'

app =
  api: null
  exapi: {}

  observer: null

  reactTicketMetricsContainers: {}

  init: (api) ->

    app.api = api
    app.id = Date.now()

    app.exapi.setUserData = Q.nbind api.userData.set, api.userData
    app.exapi.getUserData = Q.nbind api.userData.get, api.userData

    app.exapi.setCompanyData = Q.nbind api.companyData.set, api.companyData
    app.exapi.getCompanyData = Q.nbind api.companyData.get, api.companyData

    app.log = (message) ->
      error = new Error()
      stackInfo = error.stack
      stack = stackInfo.split(/\s+at /).slice(2).filter (item) ->
        item.match /\.require\./
      errorData = { message, appid: app.id, stack }
      app.exapi.setUserData new Date, errorData

module.exports = app
