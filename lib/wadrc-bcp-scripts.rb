$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'net/ssh'

require 'wadrc-bcp-scripts/basic_task'
require 'wadrc-bcp-scripts/dtitask'
require 'wadrc-bcp-scripts/fieldmap_classes'
require 'wadrc-bcp-scripts/tensor'
require 'wadrc-bcp-scripts/version'
require 'additions/NetSshConnectionSession'

# WADRC Basic Common Processing (BCP) Scripts
module WadrcBcpScripts; end
