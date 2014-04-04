#!/usr/bin/env ruby

$LOAD_PATH.unshift *Dir[File.expand_path("../../lib", __FILE__), File.expand_path("../../modules", __FILE__)]

require 'bundler'
require 'json'
require 'smart_proxy_new'

Bundler.require

Proxy::Launcher.launch

