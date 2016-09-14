require 'spec_helper'

describe LearnOpen::Opener do
  LearnOpen::Opener::HOME_DIR = File.join(__dir__, "..", "home_dir")

  context "Verifying repo existance" do
    let(:opener) { LearnOpen::Opener.new("","","") }
    before do
      path = File.join(__dir__, "..", "home_dir", "code")
      FileUtils.rm_rf(path)
    end

    context "with .cloned_labs file" do
      before do
        cloned_labs = "#{LearnOpen::Opener::HOME_DIR}/.cloned_labs"
        FileUtils.rm(cloned_labs) if File.exists?(cloned_labs)
      end
      it "returns true if lab is in the .cloned_labs file" do
        expect(opener).to receive(:repo_dir).at_least(:once).and_return("js-rubber-duck-wrangling")

        File.open("#{LearnOpen::Opener::HOME_DIR}/.cloned_labs", "w+") do |f|
          f.puts("js-rubber-duck-wrangling")
        end

        FileUtils.mkdir_p("#{opener.lessons_dir}/js-rubber-duck-wrangling")

        expect(opener.repo_exists?).to be_truthy
      end
      it "returns false if lab is not in the .cloned_labs file" do
        expect(opener).to receive(:repo_dir).and_return("js-rubber-duck-wrangling")
        expect(opener.repo_exists?).to be_falsy
      end
    end

    context "without .cloned_labs file" do
      it "returns true if directory for lab exists" do
        expect(opener).to receive(:repo_dir).and_return("js-rubber-duck-wrangling")
        FileUtils.mkdir_p("#{opener.lessons_dir}/js-rubber-duck-wrangling")

        expect(opener.repo_exists?).to be_truthy
      end

      it "returns false if directory for lab doesn't exists" do
        expect(opener).to receive(:repo_dir).and_return("js-rubber-duck-wrangling")
        expect(opener.repo_exists?).to be_falsy
      end
    end
  end
end
