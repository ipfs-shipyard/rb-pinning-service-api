json.count @pins.length

json.results @pins do |pin|
  json.partial! 'api/v1/pins/pin_status', pin: pin
end
