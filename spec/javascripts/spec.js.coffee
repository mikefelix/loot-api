# This pulls in all your specs from the javascripts directory into Jasmine:
# 
# spec/javascripts/*_spec.js.coffee
# spec/javascripts/*_spec.js
# spec/javascripts/*_spec.js.erb
# IT IS UNLIKELY THAT YOU WILL NEED TO CHANGE THIS FILE
#
#= require angular
#= require jquery
#= require_tree ../../app/assets/javascripts
#= require_tree ./