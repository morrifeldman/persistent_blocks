require "persistent_blocks/version"
require 'rake/clean'

module PersistentBlocks
  def persist(*args, &block)
    output_syms, specified_output_files, options = PBsubs.parse_inputs(args)
    marshal_output_files = PBsubs.sym_ar_to_file_list(output_syms)
    marshal_dir = PBsubs.ensure_marshal_dir
    file marshal_output_files[0] => marshal_dir unless marshal_output_files[0].nil?
    all_output_files = marshal_output_files + specified_output_files
    target_file = all_output_files[0] # rake tasks only accept one file
    params = if options[:input_overide]
               options[:input_overide]
             else
               block.parameters.map{|p| p[1]}
             end
    prereqs = PBsubs.sym_ar_to_file_list(params)
    file target_file => prereqs unless prereqs.nil?
    file target_file do |f|
      puts "Persistent_blocks: Persisting #{output_syms} and/or #{specified_output_files} from #{[*params]}"
      raw_inputs = PBsubs.load_inputs(prereqs)
      inputs = PBsubs.check_for_single_input(raw_inputs, prereqs.count)
      raw_outputs = block.(inputs)
      outputs = PBsubs.ensure_array(raw_outputs, output_syms.count)
      unless output_syms.empty?
        PBsubs.check_outputs(outputs, output_syms)
        PBsubs.display_output_info(outputs, output_syms)
        PBsubs.save_outputs(outputs, marshal_output_files) 
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

  def ensure_array(raw, n_expected)
    (n_expected == 1) ? [raw] : raw
  end

  def check_for_single_input(raw, n_expected)
    (n_expected == 1) ? raw[0] : raw
  end
  
  def sym_to_filename(sym)
    File.join(@marshal_dir, sym.to_s)
  end

  def sym_ar_to_file_list(sym_ar)
    sym_ar.map{|sym| sym_to_filename(sym)}
  end
  
  def marshal_save(object, filename)
    File.open(filename, 'w') {|io| Marshal.dump(object, io)}
  end

  def marshal_load(filename)
    #will add '.marshal' to the filename if necessary
    File.open(filename, 'r') {|io| Marshal.load(io)}
  end

  def load_inputs(filenames)
    return nil if filenames.nil? || filenames.empty?
    filenames.map{|f| marshal_load(f)}
  end

  def save_outputs(objects_to_save, filenames)
    return if objects_to_save.nil?
    return if filenames.nil? || filenames.empty?
    objects_to_save.zip(filenames).each {|o,f| marshal_save(o, f)}
  end

  def check_outputs(outputs, output_syms)
    n_expect = output_syms.count
    case n_expect
    when 0 # NP, the block might return an argument, but we don't need to save it
    when 1
      raise "Error: expecting an output (#{outputs}) from the block but got none" if outputs.nil?
      # if we get an array of outputs they will just be mapped to a single marshal file
    else
      raise "Error: expecting #{n_expect} outputs (#{output_sym}) from block but got none" if outputs.nil?
      n_received = [*outputs].count
      raise "Error: expecting #{n_expect} outputs (#{output_syms}) from block but got #{n_received} instead" if n_expect != n_received
    end
  end

  def display_output_info(outputs, output_syms)
    output_ar = output_syms.zip(outputs).map do |sym, output|
      how_long = (output.respond_to?:length) ? output.length : nil
      "#{sym} (length = #{how_long})"
    end
    puts "Block Outputs:"
    puts output_ar
  end
  
  def ensure_marshal_dir
    CLOBBER.include(@marshal_dir)
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
