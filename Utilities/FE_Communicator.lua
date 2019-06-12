--[[
	Copyright 2019 Iiau ©

	This module is licensed under the 
	Apache License 2.0
	
	A permissive license whose main conditions require preservation of copyright and license notices. 
	Contributors provide an express grant of patent rights. Licensed works, modifications, 
	and larger works may be distributed under different terms and without source code.
	
	For more information, read it here:
	http://www.apache.org/licenses/
	
	------
	
	API:
		* <String>Type is an Enum, with values 'sync' or 'async'
	
		FE.listen(<String> Type, <String> Name, <Function> Listener)
			return: <Communicator>
			> On the server, creates a new remote and listens to it.
			
		FE.request(<String> Type, <String> Name, <Variant> Args ...)
			return: nil (async), or returned arguments (sync)
			> Sends a request across client/server
			
		FE.hookUpClientRemotes(<Dictionary> Remotes)
			return: nil
			> Remotes must have this format:
			{
				['Name'] = 'async'/'sync'
				...
			}
			> Sets up remotes for the client to listen to.
				
		FE.waitForRemote(<String> Type, <String> Name, [Number: 10] Timeout)	
			return: Remote instance if exist, or nil if surpassed timeout
			> You can treat the remote instance as a boolean (on the client for example) 
			  and listening to it if it returns the instance
			
		FE.fireAllClients(<String> Name, <Variant> Args ...)
			return: nil
			> If a RemoteEvent is found with the given name and it's called on the server,
			  fire all clients with given arguments
			
		<Communicator>
			:Destroy()
			> Destroys the communicator, sets the object to nil
	
		
	
		
	
--]]

local FE = {};

local RunService 	= game:GetService('RunService');
local Server		= RunService:IsServer();

local function validType(Type)
	return (Type == 'async') or (Type == 'sync');
end;

local function parseRemote(Type)
	return (not Server) and (Type == 'RemoteFunction' and 	'OnClientInvoke'
						or									'OnClientEvent')
			or
							(Type == 'RemoteFunction' and 	'OnServerInvoke'
						or									'OnServerEvent');
end;

local function formatKeyword(Type)
	return ('Remote%s'):format((Type == 'async') and 'Event' or 'Function');
end;

function FE.hookUpClientRemotes(Args)
	assert(Server, 'You can\'t call hookUpClientRemotes(...) on the server!');
	
	for Name, Type in next, Args do
		local Inst 	= Instance.new( formatKeyword(Type) );
		Inst.Name 	= Name;
		Inst.Parent	= script;
	end;
end;

local function FindFirstChildWithClass(Parent, Name, Class)
	local Child;
	
	for _, Inst in next, Parent:GetChildren() do
		if (Inst.Name == Name and Inst:IsA(Class)) then
			Child = Inst;
			break;
		end;
	end;
	
	return Child;
end;

function FE.waitForRemote(Type, Name, Timeout)
	assert(				validType(Type), 
		'Not a valid Type string \'async\' or \'sync\''	);
	assert(Name		and typeof(Name) == 'string', 
		'Did you forget to pass a string Name?'			);

	Timeout = Timeout or 10;
	
	local ElapsedTime = 0;
	local ofType = formatKeyword(Type);
	
	while (ElapsedTime < Timeout) do
		local Inst = FindFirstChildWithClass(script, Name, ofType);
			
		if (Inst) then
			return Inst;
		end;
		
		ElapsedTime = ElapsedTime + RunService.Heartbeat:Wait();
	end;
end;

function FE.listen(Type, Name, Listener)
	-- Check for valid input::
	assert(				validType(Type), 
		'Not a valid Type string \'async\' or \'sync\''	);
	assert(Name		and typeof(Name) == 'string', 
		'Did you forget to pass a string Name?'			);
	assert(Listener and typeof(Listener) == 'function', 
		'Did you forget to pass a listener function?'	);
	
	local Self = {};
	
	Self.Type = formatKeyword(Type);
	
	local Remote = FindFirstChildWithClass(script, Name, Self.Type);
	
	if (Server) then
		if (Remote) then
			Self.Remote			= Remote;
		else
			Self.Remote 		= Instance.new(Self.Type);
			Self.Remote.Name	= Name;
			Self.Remote.Parent	= script;
		end;
	else
		assert(Remote,
			('Listened to %s but no remote was available on the server'):format(Name)
		);
		
		Self.Remote 		= Remote;
	end;
	
	if (Self.Type == 'RemoteEvent') then
		Self.Event = Self.Remote[parseRemote(Self.Type)]:Connect(Listener);
	else
		Self.Remote[parseRemote(Self.Type)] = Listener;
	end;
	
	return setmetatable(Self, {__index = FE});
end;
	
function FE.request(Type, Name, ...)
	local ofType = formatKeyword(Type);
	local Remote = FindFirstChildWithClass(script, Name, ofType);
	
	assert(Remote,
		('Requested to %s but no remote was available on the client'):format(Name)
	);
	
	return (Server) and (ofType == 'RemoteFunction' and Remote:InvokeClient(...)
					or	Remote:FireClient(...))
			or
						(ofType == 'RemoteFunction' and Remote:InvokeServer(...)
					or	Remote:FireServer(...));
end;

function FE.fireAllClients(Name, ...)
	local Remote = FindFirstChildWithClass(script, Name, 'RemoteEvent');
	if (Server and Remote) then
		Remote:FireAllClients(...);
	end;
end;

function FE:Destroy()
	if (Server and self.Remote) then
		self.Remote:Destroy();
	else
		if (self.Type == 'RemoteFunction') then
			self.Remote.OnServerInvoke = nil;
		else
			self.Event:Disconnect();
		end;
	end;
	
	self = nil;
end;

return FE;
