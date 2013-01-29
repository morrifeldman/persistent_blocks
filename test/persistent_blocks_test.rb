#!/usr/bin/env ruby
require 'minitest/autorun'
require 'persistent_blocks'

Test_rakefile = 'test_rakefile.rb'
Test_dir = 'test'
def run_rakefile(arg = '')
  `rake -I../lib -f #{Test_rakefile} #{arg}` #../lib require to locate
  #persistent_blocks because we are shelling out
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

describe 'specify task when calling perist' do
  before do
    Dir.chdir(Test_dir) do
      puts run_rakefile('clobber')
      run_rakefile('with_set_task')
      @test_task_persisted = PBsubs.marshal_load(PBsubs.sym_to_filename(:set_task))
      run_rakefile('delete_with_set_task')
      @set_task_exists = File.exists?(File.join(Test_dir, 'marshal_dir','set_task'))
      puts run_rakefile('clobber')
    end
  end
  it 'should run the test_task' do
    @test_task_persisted.must_equal 'My task was set with the :task option'
  end
  it 'the delete_task should delete the specific task' do
    @set_task_exists.must_equal false
  end
end

describe 'setting default_peristent_blocks_task' do
  before do
    Dir.chdir(Test_dir) do
      puts run_rakefile('clobber')
      run_rakefile('non_default_task')
      @non_default_peristed = PBsubs.marshal_load(PBsubs.sym_to_filename(:not_a_default_task))
      run_rakefile('delete_non_default_task')
      @non_default_task_exists = File.exists?(File.join(Test_dir, 'marshal_dir', 'not_a_default_task'))
      run_rakefile('clobber')
    end
  end
  it 'should run the non-default task' do
    @non_default_peristed.must_equal 'I am not a default task, I am a non_default_task'
  end
  it 'should run the delete_task' do
    @non_default_task_exists.must_equal false
  end
end


