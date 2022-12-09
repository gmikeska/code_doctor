# frozen_string_literal: true

RSpec.describe CodeDoctor::SourceFile do
  let(:repo) { CodeDoctor::Repository.new(path:File.join(ENV["PROJECT_DIR"],"nixon-dispatch")) }
  let(:source_file) {repo.open_local_file("/app/lib/chart_data.rb")}

  it "can open its own source files" do
    expect(source_file).not_to be nil
  end

end
