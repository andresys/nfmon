#!/usr/bin/env ruby

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..','lib'))

# require 'netflow/collector'
require 'netflow'

NetflowCollector.start_collector
