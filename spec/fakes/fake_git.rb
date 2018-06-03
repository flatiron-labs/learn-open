class FakeGit
  def clone(source, name, path:)
    FileUtils.mkdir_p("#{path}/#{name}")
    case name
    when "jupyter_lab"
      FileUtils.touch("#{path}/#{name}/requirements.txt")
    when "ios_lab"
      FileUtils.touch("#{path}/#{name}/project.xcodeproj")
    else
       nil
    end
  end
end

