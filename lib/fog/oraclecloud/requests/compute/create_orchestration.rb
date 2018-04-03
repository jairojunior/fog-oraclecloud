module Fog
  module Compute
    class OracleCloud
      class Real
        def create_orchestration(name, oplans, options = {})
          # Clean up names in case they haven't provided the fully resolved names
          name.sub! "/Compute-#{@identity_domain}/#{@username}/", ''
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
            'name' 		      => "/Compute-#{@identity_domain}/#{@username}/#{name}",
            'oplans'        => oplans,
            'relationships' => options[:relationships],
            'description'   => options[:description],
            'account'       => options[:account],
            'schedule'      => options[:schedule]
          }
          body_data = body_data.reject { |_key, value| value.nil? }
          request(
            method: 'POST',
            expects: 201,
            path: '/orchestration/',
            body: Fog::JSON.encode(body_data),
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json'
            }
          )
        end
      end

      class Mock
        def create_orchestration(name, oplans, options = {})
          response = Excon::Response.new
          # Clean up names in case they haven't provided the fully resolved names
          name.sub! "/Compute-#{@identity_domain}/#{@username}/", ''
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
          data[:orchestrations][name] = {
            'name'          => "/Compute-#{@identity_domain}/#{@username}/#{name}",
            'oplans'        => oplans,
            'relationships' => options[:relationships],
            'description'   => options[:description],
            'account'       => options[:account],
            'schedule'      => options[:schedule],
            'status'        => 'stopped',
            'uri'           => "#{@api_endpoint}orchestration/Compute-#{@identity_domain}/#{@username}/#{name}"
          }
          response.status = 201
          response.body = data[:orchestrations][name]
          response
        end
      end
    end
  end
end
