require "cutest"
require_relative "../lib/micromachine"

module Kernel
  private
  def assert_nothing_raised
    yield
    success
  rescue Exception => exception
    flunk("got #{exception.inspect} instead of nothing")
  end
end
