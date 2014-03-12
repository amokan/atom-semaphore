RestClient = require('node-rest-client').Client

module.exports =
  class SemaphoreClient
    baseURI: 'https://semaphoreapp.com/api/v1/'

    methods:
      projects: 'projects'
      branches: 'projects/${hash_id}/branches'
      status: 'projects/${hash_id}/${id}/status'

    constructor: (@authToken) ->
      @api = new RestClient
      for meth of @methods
        @api.registerMethod meth, "#{@baseURI}/#{@methods[meth]}", 'GET'

    invoke: (name, args, callback) ->
      args.parameters ?= {}
      args.headers    ?= {}
      args.parameters['auth_token'] = @authToken
      args.headers['Accept'] = 'application/json'
      @api.methods[name](args, callback)

    fetchProjects: (callback) ->
      @invoke 'projects', {}, (data, response) =>
        switch response.statusCode
          when 200
            callback(data)
          when 401
            @log 'Semaphore: API token seems to be invalid', data, response
            callback(false)
          else
            @log 'Semaphore: returned unexpected status code', data, response
            callback(false)

    fetchBranches: (hashId, callback) ->
      args =
        path:
          hash_id: hashId

      @invoke 'branches', args, (data, response) =>
        switch response.statusCode
          when 200
            callback(data)
          else
            @log 'Semaphore: returned unexpected status code', data, response
            callback(false)

    fetchStatus: (hashId, branchId, callback) ->
      args =
        path:
          hash_id: hashId
          id: branchId

      @invoke 'status', args, (data, response) =>
        switch response.statusCode
          when 200
            callback(data)
          else
            @log 'Semaphore: returned unexpected status code', data, response
            callback(false)

    log: (messages...) ->
      console.log message for message in messages
