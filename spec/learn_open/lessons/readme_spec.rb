require 'spec_helper'

describe LearnOpen::Lessons::Readme do
  let(:lesson_data) do
    {:clone_repo=>"StevenNunez/putting-it-all-together-readme-cb-000",
     :repo_name=>"putting-it-all-together-readme-cb-000",
     :repo_slug=>"StevenNunez/putting-it-all-together-readme-cb-000",
     :lab=>false,
     :lesson_id=>22935,
     :later_lesson=>true,
     :dot_learn=>{:tags=>["javascript", "react", "redux"], :languages=>["javascript"], :resources=>[1]}}
  end
  context "on unsupported environment" do
    it "opening readme" do
      environment = double("Environment", "ide?" => false, "mac?" => false)
      logger = double("Logger")
      readme = LearnOpen::Lessons::Readme.new(lesson_data,
        environment: environment,
        logger: logger)
      expect(logger).to receive(:log_failed_to_open_readme)
      readme.open
    end
  end
  context "on the IDE" do
    it "opens browser" do
      environment = double("Environment", "ide?" => true, "mac?" => false)
      logger = double("Logger")
      readme = LearnOpen::Lessons::Readme.new(lesson_data,
        environment: environment,
        logger: logger)
      expect(environment).to receive(:open_browser)
      expect(environment).to receive(:warn_skipping_lessons)
      expect(logger).to receive(:log_opening_readme)
      readme.open
    end
  end
end
