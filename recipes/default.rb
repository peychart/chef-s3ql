#
# Cookbook Name:: chef-s3ql
# Recipe:: default
#
# Copyright (C) 2015 PE, pf.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

if node['chef-s3ql']['authfilePath'] && node['chef-s3ql']['authfilePath']!=''

 # s3t package install:
 package 's3ql' do
  action :install
 end

 directory '/root/.s3ql' do
  owner 'root'
  group 'root'
  mode  '0700'
  action :create
 end

 # fstab update:
 content = ''
 ( (node['chef-s3ql']['sections'].is_a? Array) ? node['chef-s3ql']['sections'] : Array[node['chef-s3ql']['sections']] ).each do |section|
  content += '[' + section['name'] + ']' + "\n"
  content += 'backend-login: ' + section['backend-login'] + "\n"        if section['backend-login']
  content += 'backend-password: ' + section['backend-password'] + "\n"  if section['backend-password']
  content += 'storage-url: ' + section['storage-url'] + "\n"            if section['storage-url']
  content += 'fs-passphrase: ' + section['fs-passphrase'] + "\n"        if section['fs-passphrase']
  content += "\n"

  if section['device'] && section['mountPoint']
   bash 'fstab update' do
    code "grep -qsw \"#{section['device']}\" /etc/fstab || echo \"##{section['device']} #{section['mountPoint']} #{section['options']}\" >>/etc/fstab"
   end

   directory section['mountPoint'] do
    owner 'root'
    group 'root'
    mode  '0700'
    action :create
   end
  end
 end

 # authinfo file:
 file node['chef-s3ql']['authfilePath'] do
  content content
  mode  '0600'
  owner 'root'
  group 'root'
 end

 # service install:
 cookbook_file "/etc/init.d/mount-s3ql" do
  source 'mount-s3ql.sh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  notifies :reload, 'service[mount-s3ql]', :immediately
 end
 
 # service declaration:
 service "mount-s3ql" do
  start_command "/etc/init.d/mount-s3ql start"
  status_command "/etc/init.d/mount-s3ql status"
  stop_command "/etc/init.d/mount-s3ql stop"
  supports :start => true, :stop => true, :status => true
  action [ :start, :enable ]
 end

end
