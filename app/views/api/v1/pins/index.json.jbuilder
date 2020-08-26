json.count @count

json.results @pins do |pin|
  json.partial! 'api/v1/pins/pin_status', pin: pin
end
