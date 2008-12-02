class Contender
  require "yaml"
  require 'ostruct'
  
  CONTENDERS_DIR=File.expand_path(File.dirname(__FILE__) + '/../public/results/')
  
  @@cloced = Hash.new
  
  def Contender.list
    names = (Dir.entries('contenders')) - ['.','..','.gitignore']
  end
  
  def Contender.done?(name)
    @@cloced[name.to_sym].nil?
  end
  
  def Contender.yaml_load(name)
    filename = CONTENDERS_DIR+'/'+name+".yaml"
    if !File.exist?(filename)
      nil
    else
      YAML::load_file(filename)
    end
  end
  
  def command_builder(name, format='txt', save_as=nil, extra=nil)
    save_as = name+'.'+format if save_as.nil?
    command_txt = "./bin/cloc.pl -no3 --quiet contenders/#{@name} --report-file=#{CONTENDERS_DIR}/#{@save_as}.#{format}"
    command_txt << " --#{format}" if ['csv', 'xml', 'yaml'].include?(format)
  end
  
  def Contender.read_file(filename)
     if File.exist?(CONTENDERS_DIR+"/#{filename}")
       File.read(CONTENDERS_DIR+"/#{filename}")
     end
  end
  
  def Contender.cloc(name)    
    if !File.exist?("public/results/#{name}.txt")
      command_txt = "./bin/cloc.pl -no3 --quiet contenders/#{name} --report-file=public/results/#{name}.txt"
      raise 'could not generate txt output file' if !system(command_txt)
    end
    
    if !File.exist?("public/results/#{name}.yaml")
      command_yaml ="./bin/cloc.pl -no3 --quiet contenders/#{name} --report-file=public/results/#{name}.yaml --yaml"
       raise 'could not generate yaml output file' if !system(command_yaml)
    end
    yaml = (Contender.yaml_load(name))
    data = OpenStruct.new(yaml)
    data.name = name
    data.loc = yaml['Ruby']['code'] if yaml and yaml['Ruby']
    data.comments = yaml['Ruby']['comment'] if yaml and yaml['Ruby']
    @@cloced[name.to_sym] = data  #cache the result in a class variable
  end
  
  def Contender.cloc_no_test(name)
    if !Contender.read_file(name+'.txt')
      command = "./bin/cloc.pl -no3 --quiet --exclude-dir=test,spec,.git,.svn contenders/#{name} --report-file=public/results/#{name}_wo_tests.txt"
      raise 'could not generate output file' if !system(command)
    end
   
    if !Contender.read_file(name+'.yaml')
      command = "./bin/cloc.pl -no3 --quiet --exclude-dir=test,spec,.git,.svn contenders/#{name} --report-file=public/results/#{name}_wo_tests.yaml --yaml"
      raise 'could not generate output file' if !system(command)
    end
    Contender.yaml_load("#{name}_wo_tests")
  end
  
  
end