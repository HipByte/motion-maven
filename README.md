# motion-maven

motion-maven allows RubyMotion projects to integrate with the
[Maven](http://maven.apache.org/) dependency manager.


## Installation

You need to have maven installed : 

```
$ brew install maven
```

And the gem installed : 

```
$ [sudo] gem install motion-maven
```

Or if you use Bundler:

```ruby
gem 'motion-maven'
```


## Setup

1. Edit the `Rakefile` of your RubyMotion project and add the following require
   lines:

   ```ruby
   require 'rubygems'
   require 'motion-maven'
   ```

2. Still in the `Rakefile`, set your dependencies

   ```ruby
   Motion::Project::App.setup do |app|
      # ...
      app.maven do
        dependency 'com.mcxiaoke.volley', :artifact => 'library', :version => '1.0.10'
        dependency 'commons-cli'
        dependency 'ehcache', :version => '1.2.3'
      end
   end
   ```

   * Other options are : :scope, :type

   * :version will default to : LATEST

   * :artifact will default to dependency name


## Configuration

If the `mvn` command is not in your path, you can configure it :

```ruby
Motion::Project::App.setup do |app|
  # ...
  app.maven.path = '/some/path/mvn'
end
```

## Tasks

To tell motion-maven to download your dependencies, run the following rake
task:

```
$ [bundle exec] rake maven:install
```

After a `rake:clean:all` you will need to run the install task agin.

That’s all.


## Todo

* Improve the pom.xml generated file, if you are a fine Maven connoisseur, feel free to help us.
* Improve edge cases.


## Note

motion-maven does not support android support libraries, RM might support it out of the box in the future : http://hipbyte.myjetbrains.com/youtrack/issue/RM-763
