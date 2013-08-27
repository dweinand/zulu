$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)


require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/english/deny'
require 'rack/test'
require "webmock/minitest"

require 'celluloid/autostart'
require 'zulu'

Celluloid.logger = nil

