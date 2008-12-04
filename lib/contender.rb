#!/opt/local/bin/ruby
class Contender < Sequel::Model
  require "yaml"
  require 'ostruct'

  set_schema do
    primary_key :id
    varchar :name
    text :loc_report
    text :loc_report_excluding_tests
    text :yaml_loc_report
    text :yaml_loc_report_excluding_tests
    integer :lines_of_ruby
    integer :lines_of_ruby_excluding_tests
    timestamp :created_at
    timestamp :cloced_at
    varchar :repo_url
  end
  
  before_create :cloc

  def Contender.list
    names = (Dir.entries('contenders')) - ['.','..','.gitignore']
  end
  
  def read_file(filename = nil)
    filename = CONTENDERS_DIR+name+".yaml" if filename.nil?
    if File.exist?(CONTENDERS_DIR+"/#{filename}")
     File.read(CONTENDERS_DIR+"/#{filename}")
    end
  end

  def yaml_load
    YAML::load_file(CONTENDERS_DIR+'/'+name+".yaml") # if File.exist?(filename)
  end
  
  def command_builder(name, format='txt', save_as=nil, extra=nil)
    options= {:format=>'yaml'}
    save_as = name+'.'+format if save_as.nil?
    command_txt = "./bin/cloc.pl -no3 --quiet contenders/#{@name} --report-file=#{CONTENDERS_DIR}/#{@save_as}.#{format} #{extra}"
    command_txt << " --#{format}" if ['csv', 'xml', 'yaml'].include?(format)
  end
  
  def cloc    
    # command_txt = "./bin/cloc.pl -no3 --quiet contenders/#{name} --report-file=public/results/#{name}.txt"
    # puts command_txt
    # output = `#{command_txt}`
    # raise "could not generate txt output file:\n----\n#{output}" if $?.exitstatus!=0
    
    command_yaml ="./bin/cloc.pl -no3 --quiet contenders/#{name} --report-file=public/results/#{name}.yaml --yaml"
    puts command_yaml
    output = `#{command_yaml}`
    puts "\ncloc outout:\n#{output}"
    raise "could not generate yaml output file:\n #{output}\n---" unless $?.exitstatus==0 
    self.yaml_loc_report  = File.read("public/results/#{name}.yaml")
    # self.lines_of_ruby = cloc_results['Ruby']['code'] if (cloc_results and cloc_results['Ruby'])
  end
  
  def loc
    cloc_results['Ruby']['code']
  end
  
  def cloc_results
    YAML::load(yaml_loc_report) if yaml_loc_report
  end
  
  def cloc_excluding_tests
    # if !read_file(name+'.txt')CONTENDERS_DIR+'/'+name+".yaml"
    #   command = "./bin/cloc.pl -no3 --quiet --exclude-dir=test,spec,.git,.svn contenders/#{name} --report-file=public/results/#{name}_wo_tests.txt"
    #   raise 'could not generate output file' if !system(command)
    # end
   
    if !read_file(name+'.yaml')
      command = "./bin/cloc.pl -no3 --quiet --exclude-dir=test,spec,.git,.svn contenders/#{name} --report-file=public/results/#{name}_wo_tests.yaml --yaml"
      raise 'could not generate output file' if !system(command)
    end
    yaml_load("#{name}_wo_tests")
  end
  
  def cloced?
    return false if yaml_loc_report.nil?
    return false if !File.exist?("#{CONTENDERS_DIR}/#{name}.yaml")
    return false if !File.exist?(Sinatra.options.root+"/contenders/#{name}")
    return true  if File.mtime(Sinatra.options.root+"/contenders/#{name}") < File.mtime("#{CONTENDERS_DIR}/#{name}.yaml")
  end
  
  def to_s
    name
  end
  
  def results_dir
    CONTENDERS_DIR
  end
  
end