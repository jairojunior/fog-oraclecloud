module Fog
  module Compute
    class OracleCloud
      class Real
        def update_orchestration(name, oplans, options = {})
          # Clean up names in case they haven't provided the fully resolved names
          unless name.start_with?('/Compute-')
            # They haven't provided a well formed name, add their name in
            name = "/Compute-#{@identity_domain}/#{@username}/#{name}"
          end
          oplans.map do |oplan|
            oplan['objects'].map do |object|
              if oplan['obj_type'] == 'launchplan'
                object['instances'].map do |instance|
                  unless instance['name'].start_with?('/Compute-')
                    instance['name'] = "/Compute-#{@identity_domain}/#{@username}/#{instance['name']}"
                  end
                end
              else
                unless object['name'].start_with?('/Compute-')
                  object['name'] = "/Compute-#{@identity_domain}/#{@username}/#{object['name']}"
                end
              end
            end
          end
          body_data = {
            'name' 		      => name,
            'oplans'        => oplans,
            'relationships' => options[:relationships],
            'description'   => options[:description],
            'account'       => options[:account],
            'schedule'      => options[:schedule]
          }
          body_data = body_data.reject { |_key, value| value.nil? }
          request(
            method: 'PUT',
            expects: 200,
            path: "/orchestration#{name}",
            body: Fog::JSON.encode(body_data),
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json'
            }
          )
        end
      end

      class Mock
        def update_orchestration(name, oplans, options = {})
          response = Excon::Response.new
          clean_name = name.sub "/Compute-#{@identity_domain}/#{@username}/", ''
          if orchestration = data[:orchestrations][clean_name]
            oplans.map do |oplan|
              oplan['objects'].map do |object|
                if oplan['obj_type'] == 'launchplan'
                  object['instances'].map do |instance|
                    unless instance['name'].start_with?('/Compute-')
                      instance['name'] = "/Compute-#{@identity_domain}/#{@username}/#{instance['name']}"
                    end
                  end
                else
                  unless object['name'].start_with?('/Compute-')
                    object['name'] = "/Compute-#{@identity_domain}/#{@username}/#{object['name']}"
                  end
                end
              end
            end
            data[:orchestrations][clean_name].merge!(options)
            data[:orchestrations][clean_name]['oplans'] = oplans
            response.status = 200
            response.body = data[:orchestrations][clean_name]
            response
          else
            raise Fog::Compute::OracleCloud::NotFound, "Orchestration #{name} does not exist"
          end
        end
      end
    end
  end
end
