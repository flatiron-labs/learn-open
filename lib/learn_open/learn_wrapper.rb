module LearnOpen
  class LearnWrapper
    NO_OP_BLOCK = ->(_) {}
    DEFAULT_TIMEOUT = 15
    DEFAULT_RETRIES = 3
    def initialize(token:)
      @client = LearnWeb::Client.new(token: token)
      @token = token
    end

    def current_lesson(&block)
      block ||= NO_OP_BLOCK
      with_retries(->{ client.current_lesson}, &block)
    end

    def next_lesson(&block)
      block ||= NO_OP_BLOCK
      with_retries(->{ client.next_lesson}, &block)
    end

    def lesson_by_name(repo_name, &block)
      block ||= NO_OP_BLOCK
      with_retries(-> do
        client.validate_repo_slug(repo_slug: repo_name)
      end, &block)
    end

    def fork_repo(repo_name, &block)
      block ||= NO_OP_BLOCK
      block.call(:starting)
      with_retries(->{client.fork_repo(repo_name: repo_name)}, &block)
    end

    def clone_repo(full_repo_path, dest_dir, &block)
      block ||= NO_OP_BLOCK
      block.call(:starting)
      do_clone_repo(full_repo_path, dest_dir, &block)
    end

    def ping_fork_completion(full_repo_path, &block)
      block ||= NO_OP_BLOCK
      org_name, repo_name = full_repo_path.split("/")
      with_retries(-> do
          client.submit_event(
            event: 'fork',
            learn_oauth_token: token,
            repo_name: repo_name,
            base_org_name: org_name,
            forkee: { full_name: nil })
      end, &block)
    end

    private
    attr_reader :client, :token

    def with_retries(client_lambda, retries=DEFAULT_RETRIES, &block)
      begin
        Timeout::timeout(DEFAULT_TIMEOUT) do
          client_lambda.call
        end
      rescue Timeout::Error
        if retries > 0
          block.call(:retrying)
          with_retries(client_lambda, retries-1, &block)
        else
          block.call(:retries_exceeded)
        end
      end
    end

    def do_clone_repo(full_repo_path, dest_dir, retries=DEFAULT_RETRIES, &block)
      _org_name, repo_name = full_repo_path.split("/")
      begin
        Timeout::timeout(DEFAULT_TIMEOUT) do
          Git.clone("git@github.com:#{full_repo_path}.git", repo_name, path: dest_dir)
        end
      rescue Git::GitExecuteError
        if retries > 0
          block.call(:retrying) if retries > 1
          sleep(1)
          do_clone_repo(full_repo_path, dest_dir, retries-1, &block)
        else
          block.call(:retries_exceeded)
        end
      rescue Timeout::Error
        if retries > 0
          block.call(:retrying)
          do_clone_repo(full_repo_path, dest_dir, retries-1, &block)
        else
          block.call(:retries_exceeded)
        end
      end
    end
  end
end
