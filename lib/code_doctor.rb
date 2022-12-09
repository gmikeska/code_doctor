# frozen_string_literal: true

require_relative "version"
require_relative "core/regex"
require_relative "core/select"
require_relative "code_doctor/entity"
require_relative "code_doctor/language"
require_relative "code_doctor/repository"
require_relative "code_doctor/source_file"
require_relative "languages/ruby"

module CodeDoctor
  class Error < StandardError; end
  # Your code goes here...
end
