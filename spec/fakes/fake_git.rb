class FakeGit
  attr_reader :messages
  def initialize
    @messages = []
  end
  def clone(source, name, path:)
    @messages << {method: :clone, args: [source, name, {path: path}]}
    FileUtils.mkdir_p("#{path}/#{name}")
  end
end

