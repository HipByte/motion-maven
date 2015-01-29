unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

module Motion::Project
  class Config
    variable :maven

    def maven(vendor_options = {}, &block)
      @maven ||= Motion::Project::Maven.new(self)
      if block
        @maven.instance_eval(&block)
      end
      @maven
    end
  end

  class Maven
    MAVEN_ROOT = 'vendor/Maven'

    def initialize(config)
      @maven_path = 'mvn'
      @config = config
      @dependencies = []
      configure_project
    end

    def configure_project
      @config.vendor_project(:jar => 'vendor/Maven/target/dependencies.jar')
    end

    def path=(path)
      @maven_path = path
    end

    def dependency(*name_and_version_requirements)
      @dependencies << name_and_version_requirements
    end

    def generate_pom
      File.open("#{MAVEN_ROOT}/pom.xml", 'w') do |io|
        io.puts '<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">'
          io.puts '<modelVersion>4.0.0</modelVersion>'
          io.puts '<groupId>com.maventest</groupId>'
          io.puts '<artifactId>dependencies</artifactId>'
          io.puts '<packaging>jar</packaging>'
          io.puts '<version>1.0</version>'
          io.puts '<name>dependencies</name>'
          io.puts '<url>http://maven.apache.org</url>'
          io.puts '<dependencies>'
            @dependencies.map do |dependency|
              options = dependency[1] || {}
              version = options.fetch(:version, 'LATEST')
              artifact = options.fetch(:artifact, dependency[0])
              io.puts '<dependency>'
                io.puts "<groupId>#{dependency[0]}</groupId>"
                io.puts "<artifactId>#{artifact}</artifactId>"
                io.puts "<version>#{version}</version>"
              io.puts '</dependency>'
            end
          io.puts '</dependencies>'
          io.puts '<build>'
            io.puts '<plugins>'
              io.puts '<plugin>'
                io.puts '<groupId>org.apache.maven.plugins</groupId>'
                io.puts '<artifactId>maven-shade-plugin</artifactId>'
                io.puts '<executions>'
                  io.puts '<execution>'
                    io.puts '<phase>package</phase>'
                    io.puts '<goals>'
                      io.puts '<goal>shade</goal>'
                    io.puts '</goals>'
                  io.puts '</execution>'
                io.puts '</executions>'
                io.puts '<configuration>'
                  io.puts '<finalName>${artifactId}</finalName>'
                io.puts '</configuration>'
              io.puts '</plugin>'
            io.puts '</plugins>'
          io.puts '</build>'
        io.puts '</project>'
      end

      system "xmllint --output #{MAVEN_ROOT}/pom.xml --format #{MAVEN_ROOT}/pom.xml"
    end

    def install!(update)
      generate_pom
      system "#{@maven_path} -f #{MAVEN_ROOT}/pom.xml clean install"
    end
  end
end

namespace :maven do
  desc "Download and build dependencies"
  task :install do
    FileUtils.mkdir_p Motion::Project::Maven::MAVEN_ROOT
    dependencies = App.config.maven
    dependencies.install!(true)
  end
end

namespace :clean do
  # This gets appended to the already existing clean:all task.
  task :all do
    dir = Motion::Project::Maven::MAVEN_ROOT
    if File.exist?(dir)
      App.info 'Delete', dir
      rm_rf dir
    end
  end
end
