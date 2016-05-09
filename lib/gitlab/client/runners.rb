class Gitlab::Client
  # Defines methods related to build runners.
  # @see https://github.com/gitlabhq/gitlabhq/blob/master/doc/api/runners.md
  module Runners
    # Gets a list of runners.
    #
    # @example
    #   Gitlab.runners()
    #   Gitlab.runners(:scope => "active")
    #   Gitlab.runners(:all => true, :scope => "shared")
    #
    # @param          [Hash] options A customizable set of options.
    # @option options [Boolean] :all Get all runners in the GitLab instance
    #   (specific and shared). Access is restricted to users with `admin`
    #   privileges. (Default: `false`)
    # @option options [String] :scope The scope of specific runners to retrieve,
    #   one of: "active", "paused", "online". The scopes "specific" and "shared"
    #   are additionally available if :all is set to true.
    #
    # @return [Array<Gitlab::ObjectifiedHash>] The list of runners.
    def runners(options = {})
      if options.delete :all
        get("/runners/all", query: options)
      else
        get("/runners", query: options)
      end
    end

    # Get details of a runner
    #
    # @example
    #   Gitlab.runner(5)
    #
    # @param  [Integer] runner The ID of a runner.
    # @return [Gitlab::ObjectifiedHash] The runner.
    def runner(runner)
      get("/runners/#{runner}")
    end

    # Update details of a runner.
    #
    # @example
    #   Gitlab.update_runner(5, :description => "My new project description")
    #
    # @param  [Integer] runner The ID of a runner.
    # @param options [Hash] options Optional parameters for the runner
    # @option options [String] :description Description for the runner
    # @option options [Boolean] :active The state of the runner
    # @option options [Array<String>, String] :tag_list List of tags to assign to the
    #   runner. Provide an array of tags, or a comma-separated string.
    #
    # @return [Gitlab::ObjectifiedHash] The variable.
    def update_runner(runner, options = {})
      put("/runners/#{runner}", body: options)
    end

    # Remove a runner.
    #
    # @example
    #   Gitlab.remove_runner(5)
    #
    # @param [Integer] runner The ID of a runner.
    def remove_runner(runner)
      delete("/runners/#{runner}")
    end

    # List all runners (specific and shared) available in the project.
    # Shared runners are listed if at least one shared runner is defined *and* shared
    # runners usage is enabled in the project's settings.
    #
    # @example
    #   Gitlab.project_runners(10)
    #
    # @param [Integer] project The ID of a project.
    # @return [Array<GitLab::ObjectifiedHash>] The list of runners for the project.
    def project_runners(project)
      get("/projects/#{project}/runners")
    end

    # Enable an available specific runner in the project.
    #
    # @example
    #   Gitlab.enable_project_runner(10, 5)
    #
    # @param [Integer] project The ID of a project.
    # @param [Integer] runner  The ID of a runner.
    # @return [Gitlab::ObjectifiedHash] The enabled runner.
    def enable_project_runner(project, runner)
      post("/projects/#{project}/runners", body: { :runner_id => runner })
    end

    # Disable a specific runner in the project.
    # Works only if the project isn't the only project associated with the
    # specified runner. Use the Remove a Runner call instead.
    #
    # @example
    #   Gitlab.disable_project_runner(10, 5)
    #
    # @param [Integer] project The ID of a project.
    # @param [Integer] runner  The ID of a runner.
    # @return [Gitlab::ObjectifiedHash] The disabled runner.
    def disable_project_runner(project, runner)
      delete("/projects/#{project}/runners/#{runner}")
    end
  end
end
