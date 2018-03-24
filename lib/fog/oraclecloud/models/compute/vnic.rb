require 'fog/core/model'

module Fog
  module Compute
  	class OracleCloud
	    class Vnic < Fog::Model
	      identity  :name

	      attribute :description
	      attribute :tags
	      attribute :mac_address,  :aliases=>'macAddress'
	      attribute :transit_flag, :aliases=>'transitFlag'
	      attribute :uri
	    end
	  end
  end
end
