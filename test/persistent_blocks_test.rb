#!/usr/bin/env ruby
require 'minitest/autorun'

Test_rakefile = 'test_rakefile.rb'
Test_dir = 'test'
def run_rakefile(arg = '')
  `rake -f #{Test_rakefile} #{arg}`
end

describe 'persistent_blocks' do
  before do
    Dir.chdir(Test_dir) do
      puts run_rakefile('clobber')
      
      puts "\nRunning tests for the first time:\n"
      puts run_rakefile
    
      puts "\nRunning tests for the second time:\n"
      puts @second_run = run_rakefile
      
      # clean up
      puts run_rakefile('clobber')
    end
  end
  it 'should persist data' do
    @second_run.must_equal ''
  end
end

      

