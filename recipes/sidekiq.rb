# verify ruby dependency
verify_ruby 'Sidekiq - Ruby Plugin'

# check required attributes
verify_attributes do
  attributes [
                 'node[:newrelic_key]',
                 'node[:newrelic][:sidekiq][:install_path]',
                 'node[:newrelic][:sidekiq][:app_name]',
                 'node[:newrelic][:sidekiq][:uri]',
                 'node[:newrelic][:sidekiq][:namespace]',
                 'node[:newrelic][:sidekiq][:user]'
             ]
end

verify_license_key node[:newrelic][:license_key]

install_plugin 'newrelic_sidekiq_plugin' do
  plugin_version   node[:newrelic][:sidekiq][:version]
  install_path     node[:newrelic][:sidekiq][:install_path]
  plugin_path      node[:newrelic][:sidekiq][:plugin_path]
  download_url     node[:newrelic][:sidekq][:download_url]
  user             node[:newrelic][:sidekiq][:user]
end


# newrelic template
template "#{node[:newrelic][:sidekiq][:plugin_path]}/config/newrelic_plugin.yml" do
  source 'sidekiq/newrelic_plugin.yml.erb'
  action :create
  owner node[:newrelic][:sidekiq][:user]
  notifies :restart, 'service[newrelic-sidekiq-plugin]'
  variables({
                :app_name => node[:newrelic][:sidekiq][:app_name],
                :uri => node[:newrelic][:sidekiq][:uri],
                :namespace => node[:newrelic][:sidekiq][:namespace]
            })
end

# install bundler gem and run 'bundle install'
bundle_install do
  path node[:newrelic][:sidekiq][:plugin_path]
  user node[:newrelic][:sidekiq][:user]
end

# install init.d script and start service
plugin_service 'newrelic-sidekiq-plugin' do
  daemon          './newrelic_sidekiq_agent'
  daemon_dir      node[:newrelic][:sidekiq][:plugin_path]
  plugin_name     'Sidekiq'
  plugin_version  node[:newrelic][:sidekiq][:version]
  user            node[:newrelic][:sidekiq][:user]
  run_command     'bundle exec'
end
