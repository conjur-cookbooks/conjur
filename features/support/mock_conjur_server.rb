#!/usr/bin/env ruby

if $PROGRAM_NAME == __FILE__
  require 'webrick'

  server = WEBrick::HTTPServer.new Port: 80

  server.mount_proc '/authn/users/' do |req, res|
    res.body = '{}'
  end

  server.mount_proc '/authz/audit' do |req, res|
    res.body = 'ok'
    body = req.body
    File.open('/audits', 'a') { |f| f.puts body }
    puts body
  end

  trap('INT') { server.shutdown }
  server.start
end
