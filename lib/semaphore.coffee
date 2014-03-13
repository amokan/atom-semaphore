SemaphoreStatusView = require './semaphore-status-view'

module.exports =
  semaphoreStatusView: null
  configDefaults:
    authToken: 'AUTH TOKEN'

  activate: (state) ->
    if atom.workspaceView.statusBar?
      @showStatus()
    else
      atom.packages.once 'activated', =>
        @showStatus()

  deactivate: ->
    @hideStatus()

  showStatus: ->
    @semaphoreStatusView ?= new SemaphoreStatusView

  hideStatus: ->
    @semaphoreStatusView.destroy()
    @semaphoreStatusView = null
