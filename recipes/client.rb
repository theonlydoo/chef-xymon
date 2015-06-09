#
# Copyright 2011, Peter Donald
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

raise 'Unexpected platform' unless node['platform'] == 'ubuntu' or node['platform'] == 'debian'

package 'xymon-client' do
  action :install
end

package 'hobbit-plugins' do
    action :install
end

service 'hobbit-client' do
  supports :restart => true, :reload => true, :status => true
  action [:enable, :start]
end

cron "apt_update" do
    action :create
    minute '0'
    hour '4'
    user 'root'
    command %w{
    	apt-get update -qq > /var/lib/apt/update_output 2>&1 \ 
	&& [ ! -s /var/lib/apt/update_output ] \
	&& date -u > /var/lib/apt/update_success
    }.join(' ')
end

template '/etc/default/hobbit-client' do
  source 'hobbit-client.erb'
  owner 'hobbit'
  group 'hobbit'
  mode '0644'
  notifies :restart, 'service[hobbit-client]'
end
