module SubmissionHelper
  def sanitize_track( track )
    track = track.to_s.downcase.gsub(/[^a-z0-9]/, '')
    return track == '' ? '' : h("track-#{track}")
  end
  def event_image( event_id = 0, size = 32, extension = 'png' )
    url_for({:controller=>'image',:action=>:event,:id=>event_id,:size=>"#{size}x#{size}",:extension=>extension})
  end
end
