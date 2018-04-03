require 'spec_helper'

def set_env(new_env)
  new_env.each do |key, value|
    allow(ENV).to receive(:[]).with(key).and_return(value)
  end
end

describe LearnOpen::Lessons::LessonFactory do
  let(:logger) {instance_double("DebugLogger")}
  let(:editor) {"atom"}
  let(:client) {FakeClient.new}
  context "Lesson types" do
    it "sets type to readme" do
      lesson = LearnOpen::Lessons::LessonFactory.get(
        requested_lesson: "readme",
        editor: editor,
        client: client,
        logger: logger)
      expect(lesson).to be_a(LearnOpen::Lessons::Readme)
    end

    it "sets type to jupyter lab" do
      allow_any_instance_of(LearnOpen::Environments::BaseEnvironment)
        .to receive(:lesson_files)
        .and_return(["index.ipynb"])
      lesson = LearnOpen::Lessons::LessonFactory.get(
        requested_lesson: "jupyter_lab",
        editor: editor,
        client: client,
        logger: logger)
      expect(lesson).to be_a(LearnOpen::Lessons::JupyterLab)
    end

    it "sets type to generic lab" do
      lesson = LearnOpen::Lessons::LessonFactory.get(
        requested_lesson: "lab",
        editor: editor,
        client: client,
        logger: logger)
      expect(lesson).to be_a(LearnOpen::Lessons::GenericLab)
    end

    it "sets type to github disabled lab" do
      lesson = LearnOpen::Lessons::LessonFactory.get(
        requested_lesson: "no_github",
        editor: editor,
        client: client,
        logger: logger)
      expect(lesson).to be_a(LearnOpen::Lessons::GithubDisabledLab)
    end

    it "sets type to iOS lab" do
      lesson = LearnOpen::Lessons::LessonFactory.get(
        requested_lesson: "ios",
        editor: editor,
        client: client,
        logger: logger)
      expect(lesson).to be_a(LearnOpen::Lessons::IosLab)
    end
  end

  context "environments" do
    it "assigns ide v3 environment" do
      set_env({'IDE_VERSION' => "3", 'IDE_CONTAINER' => "true"})
      lesson = LearnOpen::Lessons::LessonFactory.get(
        requested_lesson: "readme",
        editor: editor,
        client: client,
        logger: logger)
      expect(lesson.environment).to be_a(LearnOpen::Environments::IDEV3Environment)
    end

    it "assigns ide legacy environment" do
      set_env({'IDE_VERSION' => nil, 'IDE_CONTAINER' => "true"})
      lesson = LearnOpen::Lessons::LessonFactory.get(
        requested_lesson: "readme",
        editor: editor,
        client: client,
        logger: logger)
      expect(lesson.environment).to be_a(LearnOpen::Environments::IDELegacyEnvironment)
    end

    it "assigns the Mac Environment" do
      original_value = RUBY_PLATFORM
      RUBY_PLATFORM = "darwin"
      lesson = LearnOpen::Lessons::LessonFactory.get(
        requested_lesson: "readme",
        editor: editor,
        client: client,
        logger: logger)
      expect(lesson.environment).to be_a(LearnOpen::Environments::MacOSXEnvironment)
      RUBY_PLATFORM = original_value
    end

    it "assigns the Generic Environment" do
      lesson = LearnOpen::Lessons::LessonFactory.get(
        requested_lesson: "readme",
        editor: editor,
        client: client,
        logger: logger)
      expect(lesson.environment).to be_a(LearnOpen::Environments::GenericEnvironment)
    end
  end
  context "fetching correct lesson" do
    it "fetches the next lesson"
    it "fetches the current lesson"
  end
end
