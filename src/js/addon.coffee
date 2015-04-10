addonEntry =
  start: (_taistApi, entryPoint) ->
    _taistApi.log 'Addon started'

    require('./greetings/hello') _taistApi

    _taistApi.companyData.set 'key', 'value ' + new Date, ->
      console.log 'company data saved'

    _taistApi.companyData.get 'key', (a, b) ->
      console.log 'received from the server', a, b

module.exports = addonEntry
