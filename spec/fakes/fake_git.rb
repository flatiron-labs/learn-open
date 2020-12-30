class FakeGit
  def clone(source, name, path:)
    FileUtils.mkdir_p("#{path}/#{name}")
    case name
    when "jupyter_lab", "python_lab"
      FileUtils.touch("#{path}/#{name}/requirements.txt")
    when "ruby_lab"
      FileUtils.touch("#{path}/#{name}/Gemfile")
    when "node_lab"
      FileUtils.touch("#{path}/#{name}/package.json")
    else
       nil
    end
  end
end

