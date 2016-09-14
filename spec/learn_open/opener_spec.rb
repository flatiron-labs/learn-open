require 'spec_helper'

describe LearnOpen::Opener do
  LearnOpen::Opener::HOME_DIR = File.join(__dir__, "..", "home_dir")

  context "Verifying repo existance" do
    let(:opener) { LearnOpen::Opener.new("","","") }
    context "with .done_labs file" do
      before do
        done_labs = "#{LearnOpen::Opener::HOME_DIR}/.done_labs"
        FileUtils.rm(done_labs) if File.exists?(done_labs)
      end
      it "returns true if lab is in the .done_labs file" do
        expect(opener).to receive(:repo_dir).and_return("js-rubber-duck-wrangling")

        File.open("#{LearnOpen::Opener::HOME_DIR}/.done_labs", "w+") do |f|
          f.puts("js-rubber-duck-wrangling")
        end

        expect(opener.repo_exists?).to be_truthy
      end
      it "returns false if lab is not in the .done_labs file" do
        expect(opener).to receive(:repo_dir).and_return("js-rubber-duck-wrangling")
        expect(opener.repo_exists?).to be_falsy
      end
    end

    context "without .done_labs file" do
      before do
        path = File.join(__dir__, "..", "home_dir", "code")
        FileUtils.rm_rf(path)
      end

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
