require 'spec_helper'

describe LearnOpen::Lessons::IosLesson do
  context ".detect" do
    subject do
      LearnOpen::Lessons::IosLesson
    end
    it "classifies if in the dot learn file" do
      swift_lesson = OpenStruct.new(dot_learn: {languages: ["objc"]})
      objc_lesson = OpenStruct.new(dot_learn: {languages: ["swift"]})
      expect(subject.detect(swift_lesson)).to be_truthy
      expect(subject.detect(objc_lesson)).to be_truthy
    end

    it "doesn't classify ruby labs" do
      ruby_lesson = OpenStruct.new(dot_learn: {languages: ["ruby"]})
      expect(subject.detect(ruby_lesson)).to be_falsey
    end

    it "handles dot learn with no languages key" do
      no_languages = OpenStruct.new(dot_learn: {})
      expect(subject.detect(no_languages)).to be_falsy
    end

    it "handles missing dot_learn file" do
      no_dot_learn_file = OpenStruct.new(nada: false)
      expect(subject.detect(no_dot_learn_file)).to be_falsy
    end
  end
end
