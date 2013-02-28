# Setup and load Bundler
require "rubygems"
require "bundler"
Bundler.setup

require "./lib/dart_indexer"
indexer = DartIndexer.new
indexer.index
