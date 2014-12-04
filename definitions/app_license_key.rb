define :app_license_key, app: nil do

  params[:app][:components].each do |component|
    if component[:collection]
      component[:collection].each do |add_on|
        if add_on[:name] =~ /New Relic/
          license_key = add_on[:config][:vars][:license_key]
          node[:newrelic][app[:name]][:license_key] = license_key
          verify_license_key license_key
        end
      end
    end
  end



end