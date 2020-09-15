json.requestid pin.id.to_s
json.status pin.status
json.created pin.created_at

json.pin do
  json.partial! 'api/v1/pins/pin', pin: pin
end
json.delegates pin.delegates
json.info pin.info
