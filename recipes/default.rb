# -*- coding: utf-8 -*-
#
# Cookbook Name:: teamcity_agent
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#

teamcity_agent_instance 'teamcity' do
  server_url node['teamcity_agent']['server_url']
end

