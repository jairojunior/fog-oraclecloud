module Fog
  module Compute
    class OracleCloud
      class SecurityAssociations < Fog::Collection
        model Fog::Compute::OracleCloud::SecurityAssociation

        def all
          data = service.list_security_associations.body['result']
          load(data)
        end

        def get(name)
          data = service.get_security_association(name).body
          new(data)
       end
      end
    end
  end
end
