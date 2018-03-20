class FakeClient
  def initialize(token: "bogus")
    @token = token
  end
  def current_lesson
  {:id=>21304,
   :title=>"Rails Dynamic Request Lab",
   :link=>"https://learn.co/lessons/21304",
   :github_repo=>"rails-dynamic-request-lab-cb-000",
   :forked_repo=>"StevenNunez/rails-dynamic-request-lab-cb-000",
   :clone_repo=>"StevenNunez/rails-dynamic-request-lab-cb-000",
   :dot_learn=>
    {:tags=>["dynamic routes", "controllers", "rspec", "capybara", "mvc"], :languages=>["ruby"], :type=>["lab"], :resources=>2},
   :lab=>true,
   :ios_lab=>false,
   :ruby_lab=>true,
   :assessments=>
    [{:type=>"fork", :passing=>true, :failing=>false, :started=>true, :message=>"You forked this lab."},
     {:type=>"local_build", :passing=>false, :failing=>false, :started=>false, :message=>"Run your tests locally to test your lab."},
     {:type=>"pull_request",
      :passing=>false,
      :failing=>false,
      :started=>false,
      :message=>"Submit a pull request on Github when you're done."}],
   :later_lesson=>false}
 end

  def next_lesson
    {:id=>21304,
    :title=>"Rails Dynamic Request Lab",
    :link=>"https://learn.co/lessons/21304",
    :github_repo=>"rails-dynamic-request-lab-cb-000",
    :forked_repo=>"StevenNunez/rails-dynamic-request-lab-cb-000",
    :clone_repo=>"StevenNunez/rails-dynamic-request-lab-cb-000",
    :dot_learn=>
   {:tags=>["dynamic routes", "controllers", "rspec", "capybara", "mvc"], :languages=>["ruby"], :type=>["lab"], :resources=>2},
    :lab=>true,
    :ios_lab=>false,
    :ruby_lab=>true,
    :assessments=>
   [{:type=>"fork", :passing=>true, :failing=>false, :started=>true, :message=>"You forked this lab."},
    {:type=>"local_build", :passing=>false, :failing=>false, :started=>false, :message=>"Run your tests locally to test your lab."},
    {:type=>"pull_request",
     :passing=>false,
     :failing=>false,
     :started=>false,
     :message=>"Submit a pull request on Github when you're done."}],
    :later_lesson=>false}
  end

  def lesson_by_name(name)
    case name
    when "lab"
      {:clone_repo=>"StevenNunez/putting-it-all-together-lab-cb-000",
       :repo_name=>"putting-it-all-together-lab-cb-000",
       :repo_slug=>"StevenNunez/putting-it-all-together-lab-cb-000",
       :lab=>true,
       :lesson_id=>22935,
       :later_lesson=>true,
       :dot_learn=>{:tags=>["javascript", "react", "redux"], :languages=>["javascript"], :resources=>[1]}}
     when "readme"
      {:clone_repo=>"StevenNunez/putting-it-all-together-readme-cb-000",
       :repo_name=>"putting-it-all-together-readme-cb-000",
       :repo_slug=>"StevenNunez/putting-it-all-together-readme-cb-000",
       :lab=>false,
       :lesson_id=>22935,
       :later_lesson=>true,
       :dot_learn=>{:tags=>["javascript", "react", "redux"], :languages=>["javascript"], :resources=>[1]}}
     when "jupyter_lab"
       {:clone_repo=>"StevenNunez/calculating-distance-lab-data-science-alpha",
       :repo_name=>"calculating-distance-lab-data-science-alpha",
       :repo_slug=>"StevenNunez/calculating-distance-lab-data-science-alpha",
       :lab=>true,
       :lesson_id=>32310,
       :later_lesson=>true,
       :dot_learn=>{:jupyter_notebook=>true}}
     when "no_github"
       {:clone_repo=>"StevenNunez/no_github",
       :repo_name=>"no_github",
       :repo_slug=>"StevenNunez/no_github",
       :lab=>true,
       :lesson_id=>32310,
       :later_lesson=>true,
       :dot_learn=>{:github=>false}}
     when "ios"
       {:clone_repo=>"StevenNunez/ios",
       :repo_name=>"ios",
       :repo_slug=>"StevenNunez/ios",
       :lab=>true,
       :lesson_id=>32310,
       :later_lesson=>true,
       :dot_learn=>{:languages => ["swift"]}}
     else
       raise "lesson not found"
    end
  end
end
