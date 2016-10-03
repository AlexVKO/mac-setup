#!/usr/bin/env ruby
require './lib/string'
require './lib/question'
require './lib/instalation'


# STARTS
p %{
  /*========================================================
  =            Welcome to alexvko Mac dev setup            =
  ========================================================*/

  Here we go!
}, :green

p  "For this I will need sudo permissions.. do you trust me? :P ", :red
`sudo -v`
abort unless $?.success?

# Global vars
@custom_installations = []
@configurations = {
  name: "Alex VKO",
  email: "ale@alexvko.com",
  ruby_version: '2.3.0'
}

# Question.new("Should I install everything without your confirmation?").
#   on(:yes){ @answers[:install_without_ask] = true }.
#   on(:no) { @answers[:install_without_ask] = false }.
#   ask

p "Checking Xcode ", :yellow

Installation.new("Oh-my-zsh").
  command("curl -L http://install.ohmyz.sh | sh").
  on(:success) {
    p "Fixing OSX zsh environment bug..."
    `if [[ -f /etc/zshenv ]]; then
      sudo mv /etc/{zshenv,zshrc}
    fi`
  }.install!

Installation.new("Homebrew").
  command('ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"').
  on(:success) {
    p "Updating brew formulas", :yellow
    `brew update`

    p "Installing GNU core utilities...", :yellow
    `brew install coreutils`

    p "Installing GNU find, locate, updatedb and xargs...", :yellow
    `brew install findutils`

    p "Installing the most recent verions of some OSX tools", :yellow
    `brew tap homebrew/dupes`
    `brew install homebrew/dupes/grep`

    `printf 'export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"' >> ~/.zshrc`
    `export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"`
  }.install!(unless: system("which brew"))

Installation.new("Git").
  command('brew install git').
  on(:success) {
    `git config --global user.name #{"@configurations.name"}`
    `git config --global user.email #{"@configurations.email"}`
  }.
  install!

Installation.new("Postgres").
  command('brew install postgresql --no-python').
  install!

Installation.new("Neovim").
  command('brew install neovim/neovim/neovim').
  on(:success) {}.# todo: alias vi=nvim
  install!

Installation.new("ImageMagick").
  command('brew install imagemagick').
  install!

Installation.new("rbenv").
  command('brew install rbenv').
  install!

Installation.new("rbenv").
  command('brew install rbenv').
  on(:success) {
    p "Setting path, shims and autocompletion ...", :yellow
    `if ! grep -qs "rbenv init" ~/.zshrc; then
      printf 'export PATH="$HOME/.rbenv/bin:$PATH"\n' >> ~/.zshrc
      printf 'eval "$(rbenv init - --no-rehash)"\n' >> ~/.zshrc

      eval "$(rbenv init -)"
    fi`

    `export PATH="$HOME/.rbenv/bin:$PATH"`
    `eval "$(rbenv init -)"`

    p "Installing rbenv-gem-rehash, we don't want to rehash everytime we add a gem...", :yellow
    `git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash`

    p "Installing ruby-build to install Rubies ...", :yellow
    `brew install ruby-build`
  }.install!

Installation.new("Openssl").
  command('brew install openssl').
  on(:success) { `brew link openssl --force` }.
  install!

Installation.new("Ruby").
  command("rbenv install #{@configurations[:ruby_version]}").
  on(:success) {
    p "set ruby version #{@configurations[:ruby_version]} to default", :yellow
    `rbenv global "#{@configurations[:ruby_version]}"`
    `rbenv rehash`
  }.on(:fail) { abort }.
  install!(unless: system("rbenv global #{@configurations[:ruby_version]}"))

Installation.new("Updating gems").
  command("gem update --system").
  on(:success) {
    p "Setup gemrc for default options", :yellow
    `printf 'gem: --no-document\n' >> ~/.gemrc`
  }.
  install!

Installation.new("Bundler").
  command("gem install bundler").
  on(:success) {
    p "Optimizing Bundler...", :yellow
    number_of_cores=`sysctl -n hw.ncpu`.to_i - 1
    `bundle config --global jobs "#{number_of_cores}"`
  }.
  install!

Installation.new("Foreman").
  command("gem install foreman").
  install!

Installation.new("Ruby on Rails").
  command("gem install rails").
  install!

Installation.new("SASS").
  command("gem install sass").
  install!

Installation.new("Heroku").
  command("brew install heroku-toolbelt").
  install!

Installation.new("Pow").
  command("curl get.pow.cx | sh").
  install!

Installation.new("Node").
  command("brew install node").
  install!

Installation.new("Grunt").
  command("npm install -g grunt-cli").
  install!

Installation.new("Cask").
  command("brew install cask").
  on(:fail) {abort}.
  install!

Installation.new("Launchrocket").
  command("brew cask install launchrocket").
  install!




p %{
  /*==============================================
  =            Lets install some apps            =
  ==============================================*/
}, :green

# Custom application
apps= %w(
  alfred
  appcleaner
  atom
  camtwist
  dropbox
  github-desktop
  google-chrome
  hammerspoon
  iterm2
  karabiner
  macvim
  obs
  rescuetime
  screenhero
  seil
  skype
  slack
  spectacle
  spotify
  sublime-text
  tomighty
  valentina-studio
  whatsapp
  zoom
)

apps.each do |app|
  Question.new("Do you want to install #{app}?").
  on(:yes){
    install_cmd = "brew cask install --appdir='/Applications' #{app}"
    @custom_installations << Installation.new(app).command(install_cmd)
  }.on(:no) { p "#{app} will not be installed", :red }.
  ask
end

@custom_installations.each(&:install!)





p %{
  /*============================================
  =            now some fonts... :)            =
  ============================================*/
}, :green

Installation.new("caskroom/fonts").
  command("brew tap caskroom/fonts").
  on(:success) {
    fonts= %w(
      font-m-plus
      font-clear-sans
      font-roboto
      font-open-sans
      font-source-sans-pro
      font-lobster
      font-alegreya
      font-montserrat
      font-inconsolata
      font-pt-sans
      font-quattrocento-sans
      font-quicksand
      font-raleway
      font-sorts-mill-goudy
      font-ubuntu
    ).each {|font| `brew cask install "#{font}"`}
  }.
  install!
