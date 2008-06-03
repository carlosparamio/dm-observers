require 'rubygems'
require 'pathname'

gem 'dm-core', '=0.9.1'
require 'data_mapper'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-observers'

require dir / 'observable'
require dir / 'observer'