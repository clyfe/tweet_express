cluster = require 'cluster'
fs = require 'fs'
path = require 'path'

master = cluster('./app')
  .in('development')
    .set('workers', 1)
    .use(cluster.reload())
    .use(cluster.logger('logs', 'debug'))
    .use(cluster.debug())
  .in('production')
    .set('workers', 4)
    .use(cluster.logger 'logs')
  .in('all')
    .set('socket path', './tmp/sockets')
    .use(cluster.stats())
    .use(cluster.pidfiles './tmp/pids')
    .use(cluster.cli())
    .use(cluster.repl 9000)
    .listen(4000);

###
master.on 'closing', ->
  for child in master.children
    fs.unlink path.resolve("#{path.join(__dirname, './tmp/sockets')}/#{child.proc.pid}.sock")
###
