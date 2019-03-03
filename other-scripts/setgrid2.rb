# Script originally from:
# https://gist.github.com/psfleming/b8b440d271404ce50fca0431befdb98a
#
# This script requires the following gems:
# - gpsd_client
# - Maidenhead

require 'gpsd_client'
require 'maidenhead'
require 'socket'
require 'json'

# This script calls to JS8Call on the following UDP port
# make sure to enable both "Accept UDP Requests" and
# "Accept Dynamic Station Information" on the Reporting tab
# of the JS&Call settings
js8call_port = 2237

gpsd = GpsdClient::Gpsd.new()
gpsd.start()
apicmd = {}

# get maidenhead if gps is ready
if gpsd.started?
  pos = gpsd.get_position
  maid = Maidenhead.to_maidenhead(pos[:lat], pos[:lon], precision = 5)
  puts "lat = #{pos[:lat]}, lon = #{pos[:lon]}, grid = #{maid}"
  apicmd = {:type => "STATION.SET_GRID", :value => maid}
end

# send if we have data
Socket.udp_server_loop(js8call_port) { |msg, msg_src|
  if apicmd.length > 0 then
    puts "Sending #{apicmd}"
    msg_src.reply apicmd.to_json
    break
  end
}
