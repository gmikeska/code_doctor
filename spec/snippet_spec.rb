# frozen_string_literal: true

RSpec.describe CodeDoctor::Snippet do
  let(:code) {
    %Q(def example_snippet
         result = 1+1
         puts results
       end)  }
  let(:snippet) {CodeDoctor::Snippet.new(code)}

  it "can open and enumerate entities" do
    expect(source_file).not_to be nil
  end

end
