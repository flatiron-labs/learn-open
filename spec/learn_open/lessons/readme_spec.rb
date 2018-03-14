require 'spec_helper'

describe LearnOpen::Lessons::Readme do
  context "on unsupported environment" do
    let(:lesson_data) do
      {:clone_repo=>"StevenNunez/putting-it-all-together-readme-cb-000",
       :repo_name=>"putting-it-all-together-readme-cb-000",
       :repo_slug=>"StevenNunez/putting-it-all-together-readme-cb-000",
       :lab=>false,
       :lesson_id=>22935,
       :later_lesson=>true,
       :dot_learn=>{:tags=>["javascript", "react", "redux"], :languages=>["javascript"], :resources=>[1]}}
    end
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
end
