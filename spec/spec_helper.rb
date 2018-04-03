require_relative '../lib/learn_open'
require_relative 'helpers/fake_client'
require 'fakefs/spec_helpers'
RSpec.configure do |config|
  config.before(:each) do
    learn_config = {
      "learn_directory"=>"~/labs", 
      "editor"=>"vim"
    }

    allow(File).to receive(:read).and_return(YAML.dump(learn_config))
  end
end

