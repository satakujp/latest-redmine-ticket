require 'yaml'
require './redmine-all-tickets.rb'

# load config.yml
config = YAML.load_file('config.yml')

# load last ticket id that had been loaded.
last_id = open('lastid').read.to_i

tickets = ReadmineTickets.new(config['host'], config['api_key'])

tickets.getTicketsFromAPI
last_id = tickets.printTicketsHash(last_id)

if(last_id != 0) then
  open('lastid', 'w').puts(last_id)
end
