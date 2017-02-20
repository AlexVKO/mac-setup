# Mac setup

It Installs everythink you need to make up and running development environmen on you mac
Written in Ruby just for FUN, and using some nice Design Patterns, so that it's REALLY easy to understand and maintain.
With that you can explicitly do what you need on a `success` callback, and if this command is required on another, you can simple abort the instalation of the whole script with `fail`, with a very nice and readable sintax, like this:

```ruby
Installation.new("Bundler").
  command("gem install bundler").
  on(:success) {
    p "Optimizing Bundler...", :yellow
    number_of_cores=`sysctl -n hw.ncpu`.to_i
    `bundle config --global jobs "#{number_of_cores - 1}"`
  }.
  on(:fail){abort}.
  install!
```

This script is already installing a BUNCH of cool things for you.

I devided it between 4 parts:
 - DevTools: it will install tools, languages, frameworks, terminal, ec, (i.e. homebrew, oh-my-zsh, Ruby, Ruby on Rails, etc..)
 - Applications
  - you can see the apps here https://github.com/AlexVKO/mac-setup/blob/master/install.rb#L210
 - Fonts
  - Check the fonts here https://github.com/AlexVKO/mac-setup/blob/master/install.rb#L259
 - OS Configurations, a bunch of configurations for improvments for your OS !
  - Check the configurations here https://github.com/AlexVKO/mac-setup/blob/master/install.rb#L283

Todo:
- Create a script to prevent clone/download
- Set up the rc files. (vim, hammerspoon, tmux, sublime,  etc...)
- Documentation generator
- Take a time to improve this document
- Display a instalation's log on finished
- Make it a library easy to init
- Create a site to store and share repos of scripts (simple list and details from readme)
