{$$, View} = require 'atom'

SemaphoreClient = require './semaphore-client'

module.exports =
  class SemaphoreStatusView extends View
    @content: ->
      @div class: 'semaphore-status-view inline-block', =>
        @span outlet: 'statusIcon'
        @span outlet: 'statusLabel'

    initialize: ->
      @repo      = atom.project.getRepo()
      @authToken = atom.config.get 'atom-semaphore.authToken'
      @fetchProjects() if @repo and @authToken?

    fetchProjects: ->
      @api = new SemaphoreClient @authToken
      @api.fetchProjects (projects) =>
        @fetchHashIdOfCurrentProject(projects) if projects?

    fetchHashIdOfCurrentProject: (projects) ->
      # We get an array of projects, and want to pick the hash_id
      # of the current project, if available.
      url = @repo.getOriginUrl()
      return unless url?
      [_, projectName] = url.match /.*github\.com:.*\/(.*)\.git/
      currentHashId  = null

      for _, project of projects
        if project['name'] == projectName
          currentHashId = project['hash_id']

      return unless currentHashId?
      @fetchCurrentBranchId(currentHashId)

    fetchCurrentBranchId: (hashId) ->
      @api.fetchBranches hashId, (branches) =>
        return unless branches?
        # We get an array of branches for the current project
        # lets see if we can find the current branch amongst them
        currentBranchId = null
        [_, branchName] = @repo.branch.match /.*\/(.*)/ # branch is e.g. refs/head/master

        for _, branch of branches
          if branch['name'] == branchName
            currentBranchId = branch['id']

        return unless currentBranchId?
        @fetchStatus(hashId, currentBranchId)

        # Do a new lookup every 10 seconds
        window.setTimeout =>
          @fetchCurrentBranchId(hashId)
        , 10000

    fetchStatus: (hashId, branchId) ->
      @api.fetchStatus hashId, branchId, (status) =>
        return unless status?

        @showStatus status.result
        @statusLabel.text "#{status.build_number} (#{status.branch_name})"


    destroy: ->
      @detach()

    notify: (message) ->
      view = $$ ->
        @div tabIndex: -1, class: 'overlay from-top', =>
          @span class: 'inline-block'
          @span "Semaphore: #{message}"

      atom.workspaceView.append view

      setTimeout ->
        view.detach()
      , 5000

    showStatus: (status) ->
      icon = switch status
        when 'pending' then 'icon-sync'
        when 'passed'  then 'icon-check'
        when 'failed'  then 'icon-alert'
        when 'stopped' then 'icon-x'
        when 'queued'  then 'icon-steps'
        else                'icon-slash'

      @statusIcon.removeClass().addClass "icon #{icon}"

      atom.workspaceView.statusBar.appendRight(this)

    hideStatus: ->
      @detach()
