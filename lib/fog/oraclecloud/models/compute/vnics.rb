require 'fog/core/collection'

module Fog
  module Compute
    class OracleCloud
      class Vnics < Fog::Collection
        model Fog::Compute::OracleCloud::Vnic

        def all
          data = service.list_vnics.body['result']
          load(data)
        end
      end
    end
  end
end
