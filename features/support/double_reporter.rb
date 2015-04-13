require 'spinach/reporter'
require 'spinach/reporter/stdout'
require 'ci/reporter/spinach'

# A Spinach reporter wrapper which forwards to CI and stdout reporters
class DoubleReporter
  REPORTERS = [::Spinach::Reporter::Stdout, ::Spinach::Reporter::CiReporter]

  def initialize *a
    @reporters = REPORTERS.map { |klass| klass.new *a }
  end

  def method_missing *a
    @reporters.each { |reporter| reporter.send *a }
  end
end
