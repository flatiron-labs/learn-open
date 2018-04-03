require 'spec_helper'

describe LearnOpen::ArgumentParser do
  context "setting editor" do
    it "reads ~/.learn-config for editor" do
      args = ["lab_name"]
      arg_parser = LearnOpen::ArgumentParser.new(args)
      expect(arg_parser.execute).to eq(["lab_name", "vim", false])
    end

    it "ignores config editor if passed in" do
      args = ["--editor=subl"]
      arg_parser = LearnOpen::ArgumentParser.new(args)
      expect(arg_parser.execute).to eq([nil, "subl", false])
    end

    it "uses config editor if editor passed in is empty" do
      args = ["--editor="]
      arg_parser = LearnOpen::ArgumentParser.new(args)
      expect(arg_parser.execute).to eq([nil, "vim", false])
    end

    it "does a think if nothing is passed in" do
      args = []
      arg_parser = LearnOpen::ArgumentParser.new(args)
      expect(arg_parser.execute).to eq([nil, "vim", false])
    end

    it "parses editor name if it has spaces" do
      args = []
      arg_parser = LearnOpen::ArgumentParser.new(args)
      expect(arg_parser.execute).to eq([nil, "vim", false])
    end
  end

  context "getting correct lab" do
    it "uses labname if passed in" do
      learn_config = {
        "learn_directory"=>"~/labs", 
        "editor"=>"vim is the best"
      }

      allow(File).to receive(:read).and_return(YAML.dump(learn_config))
      args = ["my_lab"]
      arg_parser = LearnOpen::ArgumentParser.new(args)
      expect(arg_parser.execute).to eq(["my_lab", "vim", false])
    end

    it "asks for next lesson if --next option passed in" do
      args = ["--next", "--editor=subl"]
      arg_parser = LearnOpen::ArgumentParser.new(args)
      expect(arg_parser.execute).to eq([nil, "subl", true])
    end
  end
end
