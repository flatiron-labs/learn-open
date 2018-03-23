require 'spec_helper'

describe LearnOpen::Environments::IDEV3 do
  it "knows if an environment is being opened for the corresponding lab" do
    lesson = instance_double(LearnOpen::Lessons::JupyterLab, name: "A valid lab")
    allow(ENV).to receive(:[]).with("LAB_NAME").and_return("A valid lab")
    environment = LearnOpen::Environments::IDEV3.new
    expect(environment.valid?(lesson)).to eq(true)
  end

  it "identifies environment as invalid if lab and environment lab name differ" do
    lesson = instance_double(LearnOpen::Lessons::JupyterLab, name: "A valid lab")
    allow(ENV).to receive(:[]).with("LAB_NAME").and_return("Something Different")
    environment = LearnOpen::Environments::IDEV3.new
    expect(environment.valid?(lesson)).to eq(false)
  end

  it "writes to the custom commands log to instruct the browser to open" do
    environment = LearnOpen::Environments::IDEV3.new
    file_system = double
    file_handle = double(close: nil)

    expect(file_handle).to receive(:puts)
      .with(%Q{{"command": "browser_open", "url": lesson_url}})

    expect(file_system)
      .to receive(:open)
      .with(".custom_commands.log", "a")
      .and_return(file_handle)
    environment.open_browser("http://example.com/lessons/1", file_system)
  end
end
