-- Copyright Michael Weingarden 2013.  All rights reserved.
-- credit for ResponseToTable function goes to Corona SDK
--main works well1 is last known good build

--most of this was constructed based on the advice found here:
	--https://www.dropbox.com/developers/blog/20

--//TODO: store access_token and access_secret in file so you don't have to keep authorizing
			-- allow download or upload of binary files using /media


local widget = require( "widget" )

consumer_key = ""			-- key string goes here
consumer_secret = ""		-- secret string goes here
webURL = "http://www.google.com"

mySigMethod = "PLAINTEXT"
access_token = ""
access_token_secret = ""
request_token = ""
request_token_secret = ""
accountInfo = ""

local function loadToken( type )

	local saveData = ""
	local path = system.pathForFile( type..".txt", system.DocumentsDirectory )
	local file = io.open( path, "r" )
	if file then
		--print("Found textField file")
		saveData = file:read( "*a" )
		io.close( file )
	end
	file = nil

	return saveData
end

local function storeToken( type, data )

	local path = system.pathForFile( type..".txt", system.DocumentsDirectory )
	local file = io.open( path, "w" )
	file:write( data )
	io.close( file )
	--print("Stored textField.text: "..textField.text)
	file = nil

end

local function rawGetRequest(url, rawdata, callback) 
	
	-- Callback from network loader
	local function rawGetListener( event )

		print("rawGetListener")
					
		if event.isError then
			print( "Network error!", event.status, event.response)
		else
			print ( "rawGetListener RESPONSE: ", event.status,  event.response )	-- **debug
		end

		-- the event.response is the requested data from Dropbox
		-- you can either process the response here or use a global variable or pass it to
		-- another function
		accountInfo = event.response

		-- if callback then	
		-- 	print("rawGetRequest calling back")
		-- 	callback( event.isError, event.response)		-- return with response
		-- end
	end

	print("rawdata "..rawdata)

	url = url.."?"..rawdata

	local result = network.request( url, "GET", rawGetListener)

	return result
end

local function rawPostRequest(url, rawdata, callback)
 	
	print("rawPostRequest")

	-- Callback from network loader
	local function rawPostListener( event )
					
		print("rawPostListener")

		if event.isError then
			print( "Network error!", event.status, event.response)
		else
			print ( "Dropbox RESPONSE: ", event.status,  event.response )	-- **debug
		end

		if callback then
			print("calling back from rawPostRequest")	
			callback( event.isError, event.response)		-- return with response
		end
		
	end

	local params = {}
	local headers = {}
	print("rawdata "..rawdata)
	headers["Content-Type"] = "text/plain"
	headers["Authorization"] = "OAuth "..rawdata
	params.headers = headers
	--params.body = rawdata
	
	print("rawPostRequest posting")

	local result = network.request( url, "POST", rawPostListener, params)

	print("rawPostRequest posting finished")

	return result
end


local function getRequestToken( consumer_key, token_ready_url, request_token_url,
	consumer_secret, callback )
 
	print("getRequestToken")

	--Your HTTP request should have the following header:
	--Authorization: OAuth oauth_version="1.0", oauth_signature_method="PLAINTEXT", oauth_consumer_key="<app-key>", oauth_signature="<app-secret>&"
   local post_data = "oauth_version=\"1.0\", oauth_signature_method=\""..mySigMethod.."\", oauth_consumer_key=\""
    ..consumer_key.."\", oauth_signature=\""..consumer_secret.."&\""
    return rawPostRequest(request_token_url, post_data, callback)


end


local function getAccessToken(token, token_secret, consumer_key, consumer_secret,
	access_token_url, callback)

	print("Getting access token")
    --Authorization: OAuth oauth_version="1.0", oauth_signature_method="PLAINTEXT", oauth_consumer_key="<app-key>", oauth_token="<request-token>", oauth_signature="<app-secret>&<request-token-secret>"
    local post_data =  "oauth_version=\"1.0\", oauth_signature_method=\""..mySigMethod.."\", oauth_consumer_key=\""..consumer_key.."\", oauth_token=\""..token.."\", oauth_signature=\""..consumer_secret.."&"..token_secret.."\"" 
   
    return rawPostRequest(access_token_url, post_data, callback)

end

local function responseToTable(str, delimiters)

	local obj = {}

	while str:find(delimiters[1]) ~= nil do
		if #delimiters > 1 then
			local key_index = 1
			local val_index = str:find(delimiters[1])
			local key = str:sub(key_index, val_index - 1)
	
			str = str:sub((val_index + delimiters[1]:len()))
	
			local end_index
			local value
	
			if str:find(delimiters[2]) == nil then
				end_index = str:len()
				value = str
			else
				end_index = str:find(delimiters[2])
				value = str:sub(1, (end_index - 1))
				str = str:sub((end_index + delimiters[2]:len()), str:len())
			end
			obj[key] = value
			--print(key .. ":" .. value)		-- **debug
		else
	
			local val_index = str:find(delimiters[1])
			str = str:sub((val_index + delimiters[1]:len()))
	
			local end_index
			local value
	
			if str:find(delimiters[1]) == nil then
				end_index = str:len()
				value = str
			else
				end_index = str:find(delimiters[1])
				value = str:sub(1, (end_index - 1))
				str = str:sub(end_index, str:len())
			end
			
			obj[#obj + 1] = value

		end
	end
	
	return obj
end



local function authorizeDropbox(event)

	local remain_open = true

	print("event.url: "..event.url)
	print("webURL: "..webURL)
	print("authorizeDropbox: ", event.url)
	local callbackURL = true
	local url = event.url

	if url:find("callback") then
		callbackURL = true
	else
		callbackURL = false
	end

	if url:find("oauth_token") and not callbackURL then
		remain_open = false

		function getAccess_ret( status, access_response )
			print("getAccess_ret")
			print("access_response: "..access_response)
					
			access_response = responseToTable( access_response, {"=", "&"} )
			access_token = access_response.oauth_token
			access_token_secret = access_response.oauth_token_secret
			user_id = access_response.user_id
			screen_name = access_response.screen_name
			storeToken( "access_token", access_token )
			storeToken( "access_token_secret", access_token_secret )
		end

		print("getAccess")
		getAccessToken(request_token, request_token_secret, consumer_key, 
			 consumer_secret, "https://api.dropbox.com/1/oauth/access_token", getAccess_ret )

	end

	return remain_open
end


local function requestToken_ret( status, result )

	print("requestToken_ret")
	print("result: "..result)
        
	request_token = result:match('oauth_token=([^&]+)')
	request_token_secret = result:match('oauth_token_secret=([^&]+)')

	print("request_token_secret: "..request_token_secret)

	-- Displays a webpopup to access the Twitter site so user can sign in
	-- urlRequest dictates whether the WebPopup will remain open or not
	native.showWebPopup(0, 0, 320, 480, "https://www.dropbox.com/1/oauth/authorize?oauth_token="
		.. request_token.."&oauth_callback="..webURL, {urlRequest = authorizeDropbox})
end


local function connect( event )
	print("pre request token")

	local dropbox_request = (getRequestToken(consumer_key, webURL,
		"https://api.dropbox.com/1/oauth/request_token", consumer_secret, requestToken_ret))

	print("post request token")


end

local function acctInfo_ret( status, result )
	print("acctInfo status: "..status)
	print("acctInfo: "..result)
end

local function getInfo( event )

	print("pre get info request")
	--Your HTTP request should have the following form:
	--Authorization: OAuth oauth_version="1.0", oauth_signature_method="PLAINTEXT", oauth_consumer_key="<app-key>", 
	--oauth_token="<access-token>, oauth_signature="<app-secret>&<access-token-secret>"
	--formatted for GET
	local post_data =  "oauth_version=1.0&oauth_signature_method="..mySigMethod.."&oauth_consumer_key="..consumer_key.."&oauth_token="..access_token.."&oauth_signature="..consumer_secret.."%26"..access_token_secret
	--formatted for POST which doesn't seem to work for file requests
	--local post_data =  "oauth_version=\"1.0\", oauth_signature_method=\""..mySigMethod.."\", oauth_consumer_key=\""..consumer_key.."\", oauth_token=\""..access_token.."\", oauth_signature=\""..consumer_secret.."&"..access_token_secret.."\""


    --account_info_url = "https://api.dropbox.com/1/account/info"
    account_info_url = "https://api-content.dropbox.com/1/files/dropbox/Public/2ndPeriod.csv"
   
	print("post get info request")

    local result1 = rawGetRequest(account_info_url, post_data, acctInfo_ret)
    print("rawGetRequest result: "..tostring(result1))

end

local function displayInfo()
	print("accountInfo: "..accountInfo)
end


_W = display.contentWidth
_H = display.contentHeight

access_token = loadToken( "access_token" )
access_token_secret = loadToken( "access_token_secret")

if access_token == "" then
	connectButton = widget.newButton
	{
		left = 380,
		top = _H/5,
		width = 200,
		height = 50,
		id = "button1",
		defaultFile = "smallButton.png",
		overFile = "smallButtonOver.png",
		label = "Connect",
		fontSize = 34,
		onRelease = connect
	}
	connectButton.x = _W / 2
end

getInfoButton = widget.newButton
{
	left = 380,
	top = 3*_H/5,
	width = 200,
	height = 50,
	id = "button3",
	defaultFile = "smallButton.png",
	overFile = "smallButtonOver.png",
	label = "Get Info",
	fontSize = 34,
	onRelease = getInfo
}
getInfoButton.x = display.contentWidth / 2

displayInfoButton = widget.newButton
{
	left = 380,
	top = 4*_H/5,
	width = 200,
	height = 50,
	id = "button3",
	defaultFile = "smallButton.png",
	overFile = "smallButtonOver.png",
	label = "Display Info",
	fontSize = 34,
	onRelease = displayInfo
}
displayInfoButton.x = display.contentWidth / 2