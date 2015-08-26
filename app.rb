require 'sinatra'
require 'screenshot'
require 'json'
require 'net/http'
require_relative 'json_body_params'

register Sinatra::JsonBodyParams

get '/' do
request = params[:text]
variables = request.split
command = variables[2]

settings = {:username => "foo", :password => "bar"}
client = Screenshot::Client.new(settings)

	case command

	when "hello"
	return 'hi'

	when "os"
	browsers_dict = client.get_os_and_browsers
	return_string = "The available Systems are \n\n"
	oses_list = browsers_dict.inject([]) { |list, dict| list << get_os_from_dict(dict)+" "+get_os_version_from_dict(dict) }
	return_string += oses_list.uniq.join("\n")
	return return_string

	when "os_version"

	browsers_dict = client.get_os_and_browsers
	os = variables[3]

	oses_list = browsers_dict.inject([]) { |list, dict| list << get_os_from_dict(dict)+" "+get_os_version_from_dict(dict) if match_os_from_dict(os, dict); list; }
	if oses_list
	return_string = "The available versions for this os are \n\n"
	return_string += oses_list.uniq.join("\n")
	else
	return_string = "The os you mentioned isnt available.\nTry '/screenshot browsers list' to get a list of available options\n"
	end
	return_string


	when "browsers"
	os = variables[3]
	os_version = variables[4]
	browsers_dict = client.get_os_and_browsers
	browsers_list = browsers_dict.inject([]) do |list, dict|
	list << get_browser_from_dict(dict)+" "+get_browser_version_or_device_from_dict(dict) if(match_os_version_from_dict(os, os_version, dict))
	list
	end
	if not browsers_list.empty?
	return_string = "The available browsers for this os are \n\n"
	return_string += browsers_list.uniq.join("\n")
	else
	return_string = "The os you mentioned isnt available.\nTry '/screenshot browsers list' to get a list of available options\n"
	end
	return_string


	when "browser_versions"
	os = variables[3]
	os_version = variables[4]
	browser = variables[5]
	browsers_dict = client.get_os_and_browsers
	browser_version_list = browsers_dict.inject([]) do |list, dict|
	list << get_browser_from_dict(dict)+" "+get_browser_version_or_device_from_dict(dict) if(match_browser_from_dict(os, os_version, browser, dict))
	list
	end
	if not browser_version_list.empty?
	return_string = "The available browser versions for this browser and os are \n\n"
	return_string += browser_version_list.uniq.join("\n")
	else
	return_string = "The os you mentioned isnt available.\nTry '/screenshot browsers list' to get a list of available options\n"
	end
	return_string



	when "screenshot"
	settings = {:username => variables[0], :password => variables[1]}
client = Screenshot::Client.new(settings)            

	params1 = {
		:url => "www.google.com",
		:tunnel => false,
    :callback_url => "https://fierce-dawn-5467.herokuapp.com/results",
		:browsers => [
		{:os=>"Windows",:os_version=>"7",:browser=>"ie",:browser_version=>"8.0"}]}

		params2 = {
			:url => "www.google.com",
			:tunnel => false,
      :callback_url => "https://fierce-dawn-5467.herokuapp.com/results",
			:browsers => [
			{:os => "ios", :os_version => "6.0", :device => "iPhone 5"}]}

			if variables[4].nil?
			"hello"
			else
			params1[:url]=variables[4]
			params2[:url]=variables[4]
			end 

			if variables[3]=="desktop"

			if variables[5].nil?
			"hello"
			else

			browsers_dict = client.get_os_and_browsers

			return_string = ""
			found = false
	browsers_dict.each do |dict|
if(match_browser_version_or_device_from_dict(variables[5], variables[6], variables[7], variables[8], dict))
	found = true
	params1[:browsers][0][:os]=variables[5]
	params1[:browsers][0][:os_version]=variables[6]
	params1[:browsers][0][:browser]=variables[7]
	params1[:browsers][0][:browser_version]=variables[8]
	end
	end
	if not found
	return_string = "The configuration you mentioned isnt available.\nTry '/browserstack username password os' to get a list of available options\n"
	return return_string
	end
	end

	begin
    request_id = client.generate_screenshots params1
    return "Your request is under process"
	rescue
	  return "Authentication Failed. Check username and/or password"
	end
	
  end

	if variables[3]=="mobile"

	if variables[5].nil?
	"hello"
	else

	browsers_dict = client.get_os_and_browsers

	return_string = ""
	found = false
	browsers_dict.each do |dict|
if(match_browser_version_or_device_from_dict(variables[5], variables[6], variables[7], dict))
	found = true
	params2[:browsers][0][:os]=variables[5]
	params2[:browsers][0][:os_version]=variables[6]
	params2[:browsers][0][:device]=variables[7]
	end
	end
	if not found
	return_string = "The configutaion you mentioned isnt available.\nTry '/browserstack username password os' to get a list of available options\n"
	return return_string
	end
	end

	begin
	request_id = client.generate_screenshots params2
	url = '<https://www.browserstack.com/screenshots/' + request_id + '>'
	return url
	rescue
	return "Authentication Failed. Check username and/or password"
	end  

	end 

	return "Use mobile or desktop"


	when "help"
	help_text = ""
	help_text += "You can use the screenshot command in the following ways --\n\n"
	help_text += "/browserstack [username][password] os\n"
	help_text += "/browserstack [username][password] os_version [os]\n"
	help_text += "/browserstack [username][password] browsers [os] [os_version]\n"
	help_text += "/browserstack [username][password] browser_versions [os] [os_version] [browser] \n"
	help_text += "/browserstack [username][password] screenshot [desktop] [url] [os] [os_version] [browser] [browser_version]\n"
	help_text += "/browserstack [username][password] screenshot [mobile] [url] [os] [os_version] [device]\n"
  send_text(help_text)
	return help_text

	else
	return "Wrong Command. See '/browserstack [username] [password] help' for more information"

	end

	end

def match_os_from_dict(os, dict)
	get_os_from_dict(dict).capitalize == os.capitalize
	end

	def match_os_version_from_dict os, os_version, dict
	match_os_from_dict(os, dict) && get_os_version_from_dict(dict).capitalize == os_version.capitalize
	end

	def match_browser_from_dict os, os_version, browser, dict
	match_os_version_from_dict(os, os_version, dict) && get_browser_from_dict(dict).capitalize == browser.capitalize
	end

	def match_browser_version_or_device_from_dict os, os_version, browser, browser_version, dict
	match_browser_from_dict(os, os_version, browser, dict) && get_browser_version_or_device_from_dict(dict).capitalize == browser_version.capitalize
	end

	def get_os_from_dict dict
	dict[:os].gsub("\s", "_")
	end

	def get_os_version_from_dict dict
	dict[:os_version].gsub("\s", "_")
	end

	def get_browser_from_dict dict
	dict[:browser].gsub("\s", "_")
	end

	def get_browser_version_or_device_from_dict dict
	dict[:browser_version] ? dict[:browser_version].gsub("\s", "_") : dict[:device].gsub("\s", "_")
	end

  def manage_reply(reply)
    return_string = "<"
    return_string  += reply[:screenshots][0][:image_url] + ">" 
    return return_string
  end
  
  def send_text(message, send_to=nil)
    uri = URI('https://hooks.slack.com/services/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')
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)

    request["text"] = 'VALUE1'
    data = { "text" => message }
    data[:channel] = "@"+send_to.to_s if send_to
    request.body = data.to_json

    https.request(request)
  end
  
post '/results' do
  ans = manage_reply(params)
  send_text(ans)
end