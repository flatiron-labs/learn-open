class FakeGit
  def clone(source, name, path:)
    FileUtils.mkdir_p("#{path}/#{name}")
  end
end

