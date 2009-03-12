require 'eventmachine'
Dir.glob(File.dirname(__FILE__) + '/event_utils/**/*.rb').each do |lib|
  require lib
end

module EventUtils
end
