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
   line:

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


## Tasks

To tell motion-maven to download your dependencies, run the following rake
task:

```
$ [bundle exec] rake maven:install
```

That’s all.
