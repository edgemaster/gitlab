class Gitlab::Client
  # Defines methods related to builds.
  # @see https://github.com/gitlabhq/gitlabhq/blob/master/doc/ci/triggers/README.md
  # @see https://github.com/gitlabhq/gitlabhq/blob/master/doc/api/build_triggers.md
  module BuildTriggers
    # Gets a list of the project's build triggers
    #
    # @example
    #   Gitlab.triggers(5)
    #
    # @param  [Integer] project The ID of a project.
    # @return [Array<Gitlab::ObjectifiedHash>] The list of triggers.
    def triggers(project)
      get("/projects/#{project}/triggers")
    end

    # Gets details of project's build trigger.
    #
    # @example
    #   Gitlab.trigger(5, '7b9148c158980bbd9bcea92c17522d')
    #
    # @param  [Integer] project The ID of a project.
    # @param  [String] token The token of a trigger.
    # @return [Gitlab::ObjectifiedHash] The trigger.
    def trigger_detail(project, token)
      get("/projects/#{project}/triggers/#{token}")
    end

    # Create a build trigger for a project.
    #
    # @example
    #   Gitlab.create_trigger(5)
    #
    # @param  [Integer] project The ID of a project.
    # @return [Gitlab::ObjectifiedHash] The trigger.
    def create_trigger(project)
      post("/projects/#{project}/triggers")
    end

    # Remove a project's build trigger.
    #
    # @example
    #   Gitlab.remove_trigger(5, '7b9148c158980bbd9bcea92c17522d')
    #
    # @param  [Integer] project The ID of a project.
    # @param  [String] token The token of a trigger.
    # @return [Gitlab::ObjectifiedHash] The trigger.
    def remove_trigger(project, token)
      delete("/projects/#{project}/triggers/#{token}")
    end

    # Trigger the given project build trigger.
    #
    # @see https://github.com/gitlabhq/gitlabhq/blob/master/doc/ci/triggers/README.md
    #
    # @example
    #   Gitlab.trigger_build(5, '7b9148c158980bbd9bcea92c17522d', 'master')
    #   Gitlab.trigger_build(5, '7b9148c158980bbd9bcea92c17522d', 'master', { variable1: "value", variable2: "value2" })
    #
    # @param  [Integer] project The ID of a project.
    # @param  [String] token The token of a trigger.
    # @param  [String] ref Branch name, tag name or commit SHA to build.
    # @param  [Hash] variables A set of build variables to use for the build. (optional)
    # @return [Gitlab::ObjectifiedHash] The trigger.
    # @note This method doesn't require private_token to be set.
    def trigger_build(project, token, ref, variables={})
      # Execute trigger endpoint is not under the API path
      endpoint = URI(@endpoint)
      endpoint.path = "/projects/#{project}/trigger/builds"

      options = {body: {
        token: token,
        ref: ref,
        variables: variables
      }}
      set_httparty_config options

      self.class.post(endpoint, options)
    end
  end
end
