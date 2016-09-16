require 'spec_helper'

describe LearnOpen::Opener do
  LearnOpen::Opener::HOME_DIR = File.join(__dir__, "..", "home_dir")

  context "Verifying repo existance" do
    let(:opener) { LearnOpen::Opener.new("","","") }
    after do
      path = File.join(__dir__, "..", "home_dir", "code")
      FileUtils.rm_rf(path)
    end

    context "with .cloned_labs file" do
      after do
        cloned_labs = "#{LearnOpen::Opener::HOME_DIR}/.cloned_labs"
        FileUtils.rm(cloned_labs) if File.exists?(cloned_labs)

        syncing_started = "#{LearnOpen::Opener::HOME_DIR}/.syncing_started"
        FileUtils.rm(syncing_started) if File.exists?(syncing_started)
      end

      it "returns true if lab is in the .cloned_labs file" do
        expect(opener).to receive(:repo_dir).at_least(:once).and_return("js-rubber-duck-wrangling")

        File.open("#{LearnOpen::Opener::HOME_DIR}/.cloned_labs", "w+") do |f|
          f.puts("js-rubber-duck-wrangling")
        end

        File.open("#{LearnOpen::Opener::HOME_DIR}/.syncing_started", "w+") do |f|
          f.puts("done")
        end

        FileUtils.mkdir_p("#{opener.lessons_dir}/js-rubber-duck-wrangling")

        expect(opener.repo_exists?).to be_truthy
      end

      it "returns false if lab is not in the .cloned_labs file" do
        File.open("#{LearnOpen::Opener::HOME_DIR}/.syncing_started", "w+") do |f|
          f.puts("done")
        end
        expect(opener).to receive(:repo_dir).and_return("js-rubber-duck-wrangling")
        expect(opener.repo_exists?).to be_falsy
      end

      context "before filesyncing starts" do
        it "waits for .syncing_started " do
          File.open("#{LearnOpen::Opener::HOME_DIR}/.cloned_labs", "w+") do |f|
            f.puts("js-rubber-duck-wrangling")
          end

          FileUtils.mkdir_p("#{opener.lessons_dir}/js-rubber-duck-wrangling")
          expect do
            Timeout::timeout(2) { opener.repo_exists? }
          end.to raise_error(Timeout::Error)
        end
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
