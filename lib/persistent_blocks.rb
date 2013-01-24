require "persistent_blocks/version"
require 'rake/clean'

module PersistentBlocks
  def persist(*args, &block)
    output_syms, specified_output_files, options = PBsubs.parse_inputs(args)
    marshal_output_files = [*PBsubs.sym_to_filename(output_syms)]
    marshal_dir = PBsubs.ensure_marshal_dir
    file marshal_output_files[0] => marshal_dir unless marshal_output_files[0].nil?
    all_output_files = marshal_output_files + specified_output_files
    target_file = all_output_files[0] # rake tasks only accept one file
    params = if options[:input_overide]
               options[:input_overide]
             else
               block.parameters.map{|p| p[1]}
             end
    prereqs = PBsubs.sym_to_filename(params)
    file target_file => prereqs unless prereqs.nil?
    file target_file do |f|
      puts "Persistent_blocks: Persisting #{output_syms} and/or #{specified_output_files} from #{[*params]}"
      inputs = PBsubs.load_inputs(params)
      outputs = block.(inputs)
      unless output_syms.empty?
        PBsubs.check_outputs(outputs, output_syms)
        PBsubs.save_outputs(outputs, output_syms) 
      end
      unless specified_output_files.empty?
        PBsubs.check_specified_output_files(specified_output_files)
      end
    end
    task default: target_file
    (output_syms + specified_output_files).each do |file_or_sym|
      task "delete_#{file_or_sym}" do
        all_output_files.each {|f| rm f}
      end
    end
    specified_output_files.each do |file|
      CLOBBER.include(file)
    end
    return target_file # allows file target_file => extra_dependency
  end
end

module PBsubs
  extend Rake::DSL
  extend self
  @marshal_dir = 'marshal_dir'
  attr_accessor :marshal_dir

  def sym_to_filename(symbols)
    filenames = [*symbols].map do |f|
      File.join(@marshal_dir, f.to_s)
    end
    return nil if filenames.empty?
    # unpack the array if we were just passed a single symbol
    (filenames.count == 1) ? filenames[0] : filenames
  end

  def marshal_save(object, filename)
    # will add '.marshal' to the end of the filename if it isn't already there
    File.open(sym_to_filename(filename), 'w') {|io| Marshal.dump(object, io)}
  end

  def marshal_load(filename)
    #will add '.marshal' to the filename if necessary
    File.open(sym_to_filename(filename), 'r') {|io| Marshal.load(io)}
  end

  def load_inputs(filenames)
    inputs = [*filenames].map{|f| marshal_load(f)}
    # unpack the array if there is only one filename
    ([*filenames].count == 1) ? inputs[0] : inputs
  end

  def save_outputs(objects_in, filenames_in)
    return if objects_in.nil?
    return if filenames_in.nil? || filenames_in.empty?
    filenames = [*filenames_in]
    objects = (filenames.count == 1) ? [objects_in] : objects_in
    Hash[objects.zip(filenames)].each {|o,f| marshal_save(o, f)}
  end

  def check_outputs(outputs, output_name_ar)
    n_expect = output_name_ar.count
    case n_expect
    when 0 # NP, the block might return an argument, but we don't need to save it
    when 1
      raise "Error: expecting an output (#{outputs}) from the block but got none" if outputs.nil?
      # if we get an array of outputs they will just be mapped to a single marshal file
    else
      raise "Error: expecting #{n_expect} outputs (#{output_name_ar}) from block but got none" if outputs.nil?
      n_received = [*outputs].count
      raise "Error: expecting #{n_expect} outputs (#{output_name_ar}) from block but got #{n_received} instead" if n_expect != n_received
    end
  end

  #XXX maybe we can check if this is already done!
  def ensure_marshal_dir
    CLOBBER.include(@marshal_dir) unless CLOBBER.include? @marshal_dir
    directory @marshal_dir
    @marshal_dir
  end

  def parse_inputs(input_args)
    args = input_args.dup
    options = (args[-1].is_a? Hash) ? args.pop : {}
    syms = args.select{|out| out.is_a? Symbol}
    files = args.select{|out| out.is_a? String}
    return syms, files, options
  end

  def check_specified_output_files(specified_files)
    specified_files.each do |file|
      unless File.exists? file
        raise "Error: #{file} was not created"
      end
    end
  end  
end
