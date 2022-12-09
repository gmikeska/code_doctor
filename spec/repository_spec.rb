# frozen_string_literal: true

RSpec.describe CodeDoctor::Repository do
  let(:repo) { CodeDoctor::Repository.new(path:File.join(`pwd`.chomp,'spec','fixtures', 'example_rails')) }

  it "represents a repository as an object" do
    expect(repo).not_to be nil
  end

  it "reflects its repository types" do
    expect(repo.types.length).to eq(1)
    expect(repo.types).to include(:ruby)
  end

  it "can open its own source files" do
    source_file = repo.open_local_file("config/application.rb")
    expect(source_file.language).to be :ruby
  end
end
