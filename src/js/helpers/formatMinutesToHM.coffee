module.exports = (minutes) ->
  minutes = 0 unless minutes
  minutes = parseInt minutes, 10

  h = Math.floor minutes/60
  m = ('0' + minutes%60).slice -2
  return "#{h}:#{m}"
