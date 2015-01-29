unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

unless defined?(Motion::Project::AndroidManifest)
  raise "This file must be required within a RubyMotion Android project."
end

module Motion::Project
  class Config
    variable :maven

    def maven(&block)
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
      @config.vendor_project(:jar => "#{MAVEN_ROOT}/target/dependencies.jar")
    end

    def path=(path)
      @maven_path = path
    end

    def dependency(name, options = {})
      @dependencies << normalized_dependency(name, options)
    end

    def generate_pom
      File.open(pom_path, 'w') do |io|
        xml ||= <<EOS
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.maventest</groupId>
  <artifactId>dependencies</artifactId>
  <packaging>jar</packaging>
  <version>1.0</version>
  <name>dependencies</name>
  <url>http://maven.apache.org</url>
  <dependencies>
EOS

        @dependencies.each do |dependency|
          xml << <<EOS
<dependency>
  <groupId>#{dependency[:name]}</groupId>
  <artifactId>#{dependency[:artifact]}</artifactId>
  <version>#{dependency[:version]}</version>
</dependency>
EOS
        end

        xml << <<EOS
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-shade-plugin</artifactId>
        <executions>
          <execution>
            <phase>package</phase>
            <goals>
              <goal>shade</goal>
            </goals>
          </execution>
        </executions>
        <configuration>
          <finalName>${artifactId}</finalName>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
EOS

        io.puts xml
      end

      system "xmllint --output #{pom_path} --format #{pom_path}"
    end

    def install!(update)
      generate_pom
      system "#{maven_command} -f #{pom_path} clean install"
    end

    # Helpers
    def pom_path
      "#{MAVEN_ROOT}/pom.xml"
    end

    def maven_command
      unless system("command -v #{@maven_path} >/dev/null")
        $stderr.puts "[!] #{@maven_path} command doesn’t exist. Verify your maven installation."
        exit 1
      end

      if ENV['MAVEN_DEBUG']
        "#{@maven_path} -X"
      else
        "#{@maven_path}"
      end
    end

    def normalized_dependency(name, options)
      {
        name: name,
        version: options.fetch(:version, 'LATEST'),
        artifact: options.fetch(:artifact, name)
      }
    end

    def inspect
      @dependencies.map do |dependency|
        "#{dependency[:name]} - #{dependency[:artifact]} (#{dependency[:version]})"
      end.inspect
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
