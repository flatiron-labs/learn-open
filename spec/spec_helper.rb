require_relative '../lib/learn_open'
ENV["GEM_ENV"] = "test"

def home_dir
  Dir.home
end

def create_home_dir
  FileUtils.mkdir_p home_dir
end

def create_netrc_file
  File.open("#{home_dir}/.netrc", "w+") do |f|
    f.write(<<-EOF)
machine learn-config
login learn
password some-amazing-password
    EOF
  end
  File.chmod(0600, "#{home_dir}/.netrc")
end

def create_learn_config_file
  File.open("#{home_dir}/.learn-config", "w+") do |f|
    f.write(<<-EOF)
---
:learn_directory: "#{Dir.home}/Development/code"
:editor: atom
    EOF
  end
end

def current_lesson
  {
    :id=>21304,
    :title=>"Rails Dynamic Request Lab",
    :link=>"https://learn.co/lessons/21304",
    :github_repo=>"rails-dynamic-request-lab-cb-000",
    :forked_repo=>"StevenNunez/rails-dynamic-request-lab-cb-000",
    :clone_repo=>"StevenNunez/rails-dynamic-request-lab-cb-000",
    :dot_learn=> {
      :tags=>[
        "dynamic routes",
        "controllers",
        "rspec",
        "capybara", 
        "mvc"], :languages=>["ruby"],
      :type=>["lab"],
      :resources=>2
    },
    :lab=>true,
    :ios_lab=>false,
    :ruby_lab=>true,
    :assessments=> [{
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
    }],
    :later_lesson=>false
  }
end

def next_lesson
  {
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
  }
end
