require 'ostruct'
class FakeLearnClient
  def current_lesson
    OpenStruct.new({:id=>31322,
     :title=>"Tic Tac Toe Board",
     :link=>"https://learn.co/lessons/31322",
     :github_repo=>"ttt-2-board-rb-v-000",
     :forked_repo=>"StevenNunez/ttt-2-board-rb-v-000",
     :clone_repo=>"StevenNunez/ttt-2-board-rb-v-000",
     :dot_learn=>{:tags=>["variables", "arrays", "tictactoe"], :languages=>["ruby"], :resources=>0},
     :lab=>true,
     :ios_lab=>false,
     :ruby_lab=>true,
     :assessments=>
    [{:type=>"fork", :passing=>true, :failing=>false, :started=>true, :message=>"You forked this lab."},
     {:type=>"local_build", :passing=>false, :failing=>true, :started=>true, :message=>"Build failures."},
     {:type=>"pull_request", :passing=>false, :failing=>false, :started=>false, :message=>"Submit a pull request on Github when you're done."}]})
  end

  #client.submit_event
  #client.current_lesson
  #client.next_lesson
  #client.validate_repo_slug(repo_slug: lesson)
  #client.fork_repo(repo_name: repo_dir)

  def validate_repo_slug(repo_slug:)
    case repo_slug
    when "jupyter_lab"
      OpenStruct.new({
        :clone_repo=>"StevenNunez/jupyter_lab",
        :repo_name=>"jupyter_lab",
        :repo_slug=>"StevenNunez/jupyter_lab",
        :lab=>true,
        :lesson_id=>31322,
        :later_lesson=>false,
        :dot_learn=>{
          :tags=>[
            "variables",
            "arrays",
            "tictactoe"
          ],
          :languages=>["ruby"],
          :resources=>0}
      })
    else
      OpenStruct.new({
        :clone_repo=>"StevenNunez/ttt-2-board-rb-v-000",
        :repo_name=>"ttt-2-board-rb-v-000",
        :repo_slug=>"StevenNunez/ttt-2-board-rb-v-000",
        :lab=>true,
        :lesson_id=>31322,
        :later_lesson=>false,
        :dot_learn=>{
          :tags=>[
            "variables",
            "arrays",
            "tictactoe"
          ],
          :languages=>["ruby"],
          :resources=>0}
      })
    end
  end

  def next_lesson
    OpenStruct.new({
      :id=>21304,
      :title=>"Rails Dynamic Request Lab",
      :link=>"https://learn.co/lessons/21304",
      :github_repo=>"rails-dynamic-request-lab-cb-000",
      :forked_repo=>"StevenNunez/rails-dynamic-request-lab-cb-000",
      :clone_repo=>"StevenNunez/rails-dynamic-request-lab-cb-000",
      :dot_learn=>
      {
        :tags=>[
          "dynamic routes",
          "controllers",
          "rspec",
          "capybara",
          "mvc"
        ],
        :languages=>["ruby"],
        :type=>["lab"],
        :resources=>2},
        :lab=>true,
        :ios_lab=>false,
        :ruby_lab=>true,
        :assessments=>
        [
          {
            :type=>"fork",
            :passing=>true,
            :failing=>false,
            :started=>true,
            :message=>"You forked this lab."
          },
          {
            :type=>"local_build",
            :passing=>false,
            :failing=>false,
            :started=>false,
            :message=>"Run your tests locally to test your lab."
          },
          {
            :type=>"pull_request",
            :passing=>false,
            :failing=>false,
            :started=>false,
            :message=>"Submit a pull request on Github when you're done."
          }
        ],
        :later_lesson=>false
    })
  end
end
