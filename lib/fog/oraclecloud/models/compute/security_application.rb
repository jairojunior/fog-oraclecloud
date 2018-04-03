require 'fog/core/model'

module Fog
  module Compute
    class OracleCloud
      class SecurityApplication < Fog::Model
        identity  :name

        attribute :protocol
        attribute :name
        attribute :uri
        attribute :icmptype
        attribute :proxyuri
        attribute :dport
        attribute :icmpcode

        # Only used in create
        attribute :description

        def save
          # identity ? update : create
          create
       end

        def create
          requires :name, :protocol

          data = service.create_security_application(name, protocol,
                                                     dport: dport,
                                                     icmptype: icmptype,
                                                     icmpcode: icmpcode,
                                                     description: description)
          merge_attributes(data.body)
        end

        def destroy
          requires :name
          service.delete_security_application(name)
        end
      end
    end
  end
end
