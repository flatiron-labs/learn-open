class FakeGit
  def clone(source, name, path:)
    FileUtils.mkdir_p("#{path}/#{name}")
    case name
    when "jupyter_lab"
      FileUtils.touch("#{path}/#{name}/requirements.txt")
    else
       nil
    end
  end
end

