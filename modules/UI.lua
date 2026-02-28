return function(className, props)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		if type(k) == "number" then
			v.Parent = inst
		elseif k == "Events" then
			for evName, evFunc in pairs(v) do
				inst[evName]:Connect(evFunc)
			end
		else
			inst[k] = v
		end
	end
	return inst
end