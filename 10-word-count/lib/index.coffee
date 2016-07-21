through2 = require 'through2'


module.exports = ->
  words = 0
  lines = 0
  characters = 0

  prefix = ''

  splitLines = (chunk) ->
    data = chunk.toString()
    if prefix.length > 0
      data = prefix + data
      prefix = ''
    totalLines = data.toString().split '\n'
    last = totalLines.pop()
    if data.endsWith '\n'
      totalLines.push last
    else
      prefix = last
    return totalLines

  processQuoted = (line) ->
    re = /"([^"]*)"/g
    totalWords = line.match re
    if !totalWords then return line
    # count words
    words += totalWords.length
    line = line.replace(re, ' ')
    return line

  processCamel = (word) ->
    re = /[A-Z]+/g
    word = word.replace(re, ' ')
    if word && word[0] != ' '
      word = ' ' + word
    count = (word.match(/ /g) || []).length
    words += count

  processWords = (line) ->
    cleanLine = processQuoted line
    re = /[A-Za-z0-9]+/g
    totalWords = cleanLine.match(re)
    if !totalWords then return
    for word in totalWords when word
      processCamel word

  transform = (chunk, encoding, cb) ->
    totalLines = splitLines chunk
    processedLines = totalLines.filter (obj) ->
      return obj.length > 0 ? true : false
    # count line
    lines += processedLines.length
    for line in processedLines when line && line.length > 0
      # count characters
      characters += line.length + 1
      processWords line
    return cb()

  flush = (cb) ->
    # process last line
    if prefix.length > 0
      lines += 1
      characters += prefix.length
      processWords prefix
    this.push {words, lines, characters}
    this.push null
    return cb()

  return through2.obj transform, flush