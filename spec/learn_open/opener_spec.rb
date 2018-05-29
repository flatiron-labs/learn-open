require 'spec_helper'

describe LearnOpen::Opener do
  LearnOpen::Opener::HOME_DIR = File.join(__dir__, "..", "home_dir")

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
    netrc_adapter = double("Netrc adapter", read: {'learn-config' => ["learn", "some-amazing-password"]})
    opener = LearnOpen::Opener.new("", "", "", netrc_adapter: netrc_adapter)
    expect(opener.token).to eq("some-amazing-password")
  end

  it "instantiates client with token" do
    learn_client_class = double("Learn Client Double")
    netrc_adapter = double("Netrc adapter", read: {'learn-config' => ["learn", "some-amazing-password"]})
    expect(learn_client_class).to receive(:new).with(token: "some-amazing-password")
    LearnOpen::Opener.new("", "", "", netrc_adapter: netrc_adapter, learn_client_class: learn_client_class)
  end

  it "loads lesson directory from learn-config" do
    learn_config = File.read(File.join(__dir__, "..", "fixtures", "learn-config"))
    home_dir = File.join(__dir__, "..", "home_dir")
    file_access_adapter = double("File Adapter", expand_path: home_dir, read: learn_config) # gross, write proper wrapper

    opener = LearnOpen::Opener.new("", "", "", netrc_adapter: spy, learn_client_class: spy, file_access_adapter: file_access_adapter)
    expect(opener.file_path).to eq("#{home_dir}/.learn-open-tmp")
  end

  context "Fetching lesson" do
  end
end
