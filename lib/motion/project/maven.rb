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
          options = dependency[1] || {}
          version = options.fetch(:version, 'LATEST')
          artifact = options.fetch(:artifact, dependency[0])
          xml << <<EOS
<dependency>
  <groupId>#{dependency[0]}</groupId>
  <artifactId>#{artifact}</artifactId>
  <version>#{version}</version>
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
