require_relative "../code_doctor/language"

module CodeDoctor
  module Languages
    class Ruby < CodeDoctor::Language
      def initialize
        @default_file_type = "rb"
        @file_types = %I[Appfile
           Appraisals
           arb
           Berksfile
           Brewfile
           cap
           Capfile
           capfile
           cgi
           cr
           Dangerfile
           Deliverfile
           Fastfile
           fcgi
           gemspec
           Guardfile
           irbrc
           opal
           Podfile
           podspec
           prawn
           pryrc
           Puppetfile
           rabl
           rake
           Rakefile
           Rantfile
           rb
           rbx
           rjs
           ru
           ruby
           Schemafile
           Snapfile
           thor
           Thorfile
           Vagrantfile
         ]
         @default_repo_type = :ruby
         @repo_types = {
           ruby_gem:{
             has_file:"*.gemspec",
             subdirectories:{
               bin:"/bin",
               lib:"/lib",
               exe:"/exe"
             }
           },
           ruby:{
              has_file:"Gemfile",
              subdirectories:{
                bin:"/bin",
                lib:"/lib",
                exe:"/exe"
              }
             }
           }
         @file_extension = {default:"rb", alias:@file_types}
         @entity_types = ["module","class","method"]
      end

      def selector_for(entity_type)
        Regexp::Template.new(atoms:[:"#{entity_type} ", Regexp::Template.capture_group([:"[^\(]*"],name:"#{entity_type}_name")]).rx
      end
    end
  end
end
