assert = require 'assert'
fs = require 'fs'
WordCount = require '../lib'


helper = (input, expected, done) ->
  pass = false
  counter = new WordCount()

  counter.on 'readable', ->
    return unless result = this.read()
    assert.deepEqual result, expected
    assert !pass, 'Are you sure everything works as expected?'
    pass = true

  counter.on 'end', ->
    if pass then return done()
    done new Error 'Looks like transform fn does not work'

  counter.write input
  counter.end()


describe '10-word-count', ->

  it 'should count a single word', (done) ->
    input = 'test'
    expected = words: 1, lines: 1, characters: 4
    helper input, expected, done

  it 'should count words in a phrase', (done) ->
    input = 'this is a basic test'
    expected = words: 5, lines: 1, characters: 20
    helper input, expected, done

  it 'should count quoted characters as a single word', (done) ->
    input = '"this is one word!"'
    expected = words: 1, lines: 1, characters: 19
    helper input, expected, done

  # !!!!!
  # Make the above tests pass and add more tests!
  # !!!!!
  it 'should count number as word', (done) ->
    input = '12 34 56'
    expected = words: 3, lines: 1, characters: 8
    helper input, expected, done

  it 'should count quoted characters without quote mark inside as a single word', (done) ->
    input = '"this is one word!" another"'
    expected = words: 2, lines: 1, characters: 28
    helper input, expected, done

  it 'should count camelCase as two words', (done) ->
    input = 'camelCase'
    expected = words: 2, lines: 1, characters: 9
    helper input, expected, done

  it 'should count CamelCase as two words', (done) ->
    input = 'CamelCase'
    expected = words: 2, lines: 1, characters: 9
    helper input, expected, done

  it 'should count TCamelCase as two words', (done) ->
    input = 'TCamelCase'
    expected = words: 2, lines: 1, characters: 10
    helper input, expected, done

  it 'should not count special characters as word', (done) ->
    input = '` ! @ # $ % ^ & * ( ) - + * / _ = { } [ ] : ; " , . ?'
    expected = words: 0, lines: 1, characters: 53
    helper input, expected, done

  it 'should count fixture files correctly', (done) ->
    dir = "#{__dirname}/fixtures/"
    files = fs.readdirSync dir, { encoding: 'utf8' }

    getPromise = (file) ->
      filenameBlocks = file.split '.'
      if filenameBlocks.length > 1
        filenameBlocks.pop()
      filenameBase = filenameBlocks.join ''
      results = filenameBase.split ','
      expected = words: results[1], lines: results[0], characters: results[2]
      input = fs.readFileSync dir + file
      new Promise (resolve, reject) ->
        helper input, expected, resolve

    Promise.all(files.map (file) ->
      getPromise file
    ).then(done())

