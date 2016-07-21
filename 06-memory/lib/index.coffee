fs = require 'fs'


exports.countryIpCounter = (countryCode, cb) ->
  return cb() unless countryCode

  counter = 0
  prefix = ''
  inputFile = fs.createReadStream "#{__dirname}/../data/geo.txt", { encoding: 'utf8' }
  inputFile.on 'data', (chunk) ->
    if prefix.length > 0
      chunk = prefix + chunk
      prefix = ''
    data = chunk.toString().split '\n'
    last = data.pop()
    # check if last is a line
    if chunk.endsWith '\n'
      data.push last
    else
      prefix = last
    for line in data when line
      blocks = line.split '\t'
      if blocks[3] == countryCode
        counter += +blocks[1] - +blocks[0]

  inputFile.on 'end', () ->
    cb null, counter