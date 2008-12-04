require 'rubygems'
require 'sequel'

DB = Sequel.connect('sqlite://locbattle.db')
if !DB.table_exists?('contenders')
  DB.create_table('contenders') do
      primary_key :id
      varchar :name
      text :loc_report
      text :loc_report_excluding_tests
      text :yaml_loc_report
      text :yaml_loc_report_excluding_tests
      integer :lor
      integer :lor_excluding_tests
      timestamp :created_at
      timestamp :run_at
      varchar :repo_url
  end 
end
