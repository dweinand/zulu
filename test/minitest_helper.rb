$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'zulu'

require 'minitest/autorun'
require 'minitest/english/deny'

require 'rack/test'
require "webmock/minitest"
