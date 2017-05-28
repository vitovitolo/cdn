require 'json'
require 'sinatra/base'
require 'sinatra/config_file'

class Stats < Sinatra::Base
   register Sinatra::ConfigFile
   config_file '/var/www/stats/config.yml'

   def is_request(line)
	begin
	  http_version = line.split(" ")[19].delete! '"'
	rescue
	  http_version = "error"
	end
	if http_version =~ /HTTP/
	  true
	else
	  false
	end
   end

   def get_time(line)
	begin
	  string = line.split(" ")[6].delete! '[]'
	  parts = string.split(/[\/:.]/)
	  Time.local(*parts.values_at(2, 1, 0, 3..6))
	rescue
	  Time.local(1970, 1, 1)
	end
   end

   def count_requests(filename, days=1)
	t_yesterday_date = Time.now - days*24*60*60
	t_now = Time.now
	counter = 0

	File.foreach(filename) do |line|
	   if is_request(line)
		   t_line_date = get_time(line)
		   if t_line_date > t_yesterday_date and t_line_date < t_now
			counter += 1
		   end
	   end
	end
	counter
   end

   get "/" do
      content_type :json
      { :requests => count_requests(settings.proxy_log) }.to_json
   end
end

