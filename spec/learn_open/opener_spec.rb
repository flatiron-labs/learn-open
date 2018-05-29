require 'spec_helper'
require 'fakefs/spec_helpers'

describe LearnOpen::Opener do
  include FakeFS::SpecHelpers
  #context "Verifying repo existance" do
  #  let(:opener) { LearnOpen::Opener.new("","","") }
  #  after do
  #    path = File.join(__dir__, "..", "home_dir", "code")
  #    FileUtils.rm_rf(path)
  #  end

  #  it "returns true if .git directory for lab exists" do
  #    expect(opener).to receive(:repo_dir).and_return("js-rubber-duck-wrangling")
  #    FileUtils.mkdir_p("#{opener.lessons_dir}/js-rubber-duck-wrangling/.git")

  #    expect(opener.repo_exists?).to be_truthy
  #  end

  #  it "returns false if directory for lab doesn't exists" do
  #    expect(opener).to receive(:repo_dir).and_return("js-rubber-duck-wrangling")
  #    expect(opener.repo_exists?).to be_falsy
  #  end
  #end

  let(:learn_client_class) { double("Learn Client Class Double") }

  before do
    create_home_dir
    create_netrc_file
    create_learn_config_file
  end
  context "asking for a specific lesson" do
    it "sets the lesson" do
      opener = LearnOpen::Opener.new("ttt-2-board-rb-v-000","", false)
      expect(opener.lesson).to eq("ttt-2-board-rb-v-000")
    end
  end

  context "setting specific editor" do
    it "sets the editor" do
      opener = LearnOpen::Opener.new("", "atom", false)
      expect(opener.editor).to eq("atom")
    end
  end

  context "asking for next lesson" do
    it "sets the whether to open the next lesson or not" do
      opener = LearnOpen::Opener.new("", "", true)
      expect(opener.get_next_lesson).to eq(true)
    end
  end

  it "reads the token from the .netrc file" do
    opener = LearnOpen::Opener.new("", "", "")
    expect(opener.token).to eq("some-amazing-password")
  end

  it "instantiates client with token" do
    expect(learn_client_class).to receive(:new).with(token: "some-amazing-password")
    LearnOpen::Opener.new("", "", "", learn_client_class: learn_client_class)
  end

  it "loads lesson directory from learn-config" do
    opener = LearnOpen::Opener.new("", "", "", learn_client_class: spy)
    expect(opener.file_path).to eq("#{home_dir}/.learn-open-tmp")
  end

  context "running the opener" do
    it "opens the next lesson" do
      learn_client_double = double("Learn Client Instance Double", 
                                   next_lesson: double(next_lesson))
      # Need smarter object here that creates dir on "Clone"
      # Or we can change the endpoint to clone from based on environment (local)
      git_adapter = spy("Git Spy")
      expect(git_adapter).to receive(:clone).with("git@github.com:StevenNunez/ttt-2-board-rb-v-000.git", "", path: "")

      expect(learn_client_double)
        .to receive(:fork_repo)
        .with(repo_name: "rails-dynamic-request-lab-cb-000")

      expect(learn_client_class).to receive(:new)
        .with(token: "some-amazing-password")
        .and_return(learn_client_double)

      opener = LearnOpen::Opener.new(nil, "", true, learn_client_class: learn_client_class, git_adapter: git_adapter)
      opener.run
      expect(opener.lesson).to eq("StevenNunez/ttt-2-board-rb-v-000")
      expect(opener.lesson_is_lab).to eq(false)
      expect(opener.later_lesson).to eq(false)
      expect(opener.dot_learn).to eq({:tags=>["variables", "arrays", "tictactoe"], :languages=>["ruby"], :resources=>0})
    end
    it "opens a specified lesson" do
    end
  end
end

=begin
Things to test
Logging
Setting the "lesson" we're going to be opening
  name passed in? asked for next? Nothing passed in?
=end

