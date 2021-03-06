require "persistent_blocks"
require 'debugger'

extend PersistentBlocks

persist :test do
  puts "running the first task"
  puts a = [1,2,3]
  a
end

persist :test2 do |test|
  puts "running the second task"
  puts "input = #{test}"
  'I do not want to be packed into an array'
end

persist :test3, :test4  do |test2|
  puts "About to simulate a 2 sec calc"
  sleep(2)
  puts "test2 = #{test2}"
  puts "test2 = '#{test2}', it should not be an array"
  [test2*1, test2.upcase]
end

persist :task4 do |test3, test4|
  puts "running the 4th task"
  puts "test3 = #{test3}"
  puts "test4 = #{test4}"
  ['String Output\nSecond Line', {test: 1, :test => [1, 2, 3]}]
end

persist :no_paren do
  'no parentheses'
end

persist :overide_test, input_overide: [:test3, :test4] do |x,y|
  puts "test3 (#{x}) was mapped to x"
  puts "test4 (#{y})) was mapped to y"
  1
end

persist :overide_test_no_bracket, :input_overide => :test3 do |x|
  puts "input overide also works without brackets"
end

persist :set_task, :task => :with_set_task do
  'My task was set with the :task option'
end

PBsubs.default_persistent_blocks_task = :non_default_task
persist :not_a_default_task do
  'I am not a default task, I am a non_default_task'
end

#persist(:should_fail1, :should_fail_2) do
#  'one_output, but expecting two'
#end

#persist (:should_fail) do
#  puts "This task should fail because it doesn't return anything"
#end



