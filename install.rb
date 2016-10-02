#!/usr/bin/env ruby
require './lib/string'
require './lib/questions'

# STARTS
p %{
  /*========================================================
  =            Welcome to alexvko Mac dev setup            =
  ========================================================*/

  I will install a bunch of things for you!
}, :blue

@answers = {}
Question.new("Should I install everything without your confirmation?").
  on(:yes){ @answers[:install_without_ask] = true }.
  on(:no) { @answers[:install_without_ask] = false }.
  ask
