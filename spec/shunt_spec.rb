$LOAD_PATH << './lib'

require 'tokenise'
require 'shunt'

describe Shunt do
  describe 'encountered bugs' do
    it '.level = "error" || ( .name = "AMQPSender" && .message = "Data to be sent" )' do
      a = Tokenise.process('.level = "error" || ( .name = "AMQPSender" && .message = "Data to be sent" )')
      expect { Shunt.process(a) }.not_to raise_error
    end
  end
end
