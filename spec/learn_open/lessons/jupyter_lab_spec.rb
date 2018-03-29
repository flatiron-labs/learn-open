require 'spec_helper'

def set_env(new_env)
  new_env.each do |key, value|
    allow(ENV).to receive(:[]).with(key).and_return(value)
  end
end

describe LearnOpen::Lessons::JupyterLab do
  it "knows if a lab is a jupyter lab" do
    lesson_data = {repo_name: "Repo Name"}
    environment = double(lesson_files: ["index.ipynb"])
    expect(LearnOpen::Lessons::JupyterLab.detect(lesson_data, environment)).to eq(true)
  end
end
