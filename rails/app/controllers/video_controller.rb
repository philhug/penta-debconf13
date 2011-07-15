class VideoController < ApplicationController
  before_filter :init
  around_filter :update_last_login
  before_filter :check_recording_lock, :only=>[:associate, :link_to_event, :mark_for_deletion]
  before_filter :check_target_file_lock, :only=>[:rate_file, :vtf_rating]

  def index
    @content_subtitle = local("video::list_recordings")
    @map_vfs_to_s = {}
    Video_file_status.select.each { |vfs| @map_vfs_to_s[vfs.id] = vfs.file_status_code }

    @recordings = Video_recording.select({:conference_id=>@current_conference.conference_id}, {:order=>[:recording_time]})
  end

  def associate
    @content_subtitle = local("video::associating_recording")
    @video = Video_recording.select({:id => params[:id]}).first
    @room = Conference_room.select({:conference_id=> @video.conference_id, :conference_room => @video.conference_room}).first
    @distances = View_event_recording_distance.select({:conference_id => @video.conference_id, :conference_room => @video.conference_room, :recording_id=>@video.id})
  end

  def link_to_event
    @content_subtitle = local("video::linking_recording")
    @rec = Video_recording.select_single({:id => params[:id]})
    @event = Event.select({:event_id => params[:event_id]}).first
    @base_name = sprintf('%03d_',@rec.id) + @event.title.gsub(/[^\s\w\d\.\+\_\-]/, '').gsub(/\s+/,'_').gsub(/\.$/,'')
    @ver = Video_event_recording.new(:event_recording_base_name => @base_name, :event_id => @event.event_id, :recording_id => @rec.id)
  end

  def ev_rec_data
    #TODO: this prefix thing should be moved to the
    #      video_event_recording model
    prefix = sprintf('%03d_', params[:video_recording][:id])
    params[:video_event_recording][:event_recording_base_name] = prefix + params[:video_event_recording][:event_recording_base_name] if params[:video_event_recording][:event_recording_base_name][0..prefix.length-1] != prefix

    # FIXME: UGLY!
    params[:video_event_recording][:start_time] = "00:00:00" if params[:video_event_recording][:start_time].empty?
    params[:video_event_recording][:end_time] = Video_recording.select_single({:id => params[:video_recording][:id]}).recording_duration if params[:video_event_recording][:end_time].empty?

    ver = write_row(Video_event_recording, params[:video_event_recording])
    rec = write_row(Video_recording, params[:video_recording], {:preset => {:conference_id => @current_conference.conference_id}})
    redirect_to( :action => 'index' )
  end

  def unlink_from_event
    @ver = Video_event_recording.select_single(:id => params[:id]).delete
    redirect_to( :action => 'index' )
  end

  def transcodings
    @content_subtitle = local("video::transcoding_status")
    @formats = Video_target_format.select
    @recordings = Video_recording.select({:conference_id => @current_conference.conference_id}, {:order=>[:recording_time]})
    @map_vfs_to_s = {}
    Video_file_status.select.each { |vfs| @map_vfs_to_s[vfs.id] = vfs.file_status_code }
  end

  def rate_file
    @content_subtitle = local("video::rate_file")
    @vtf = Video_target_file.select_single({:id => params[:id]})
    @ver = Video_event_recording.select_single({:id => @vtf.event_recording_id})
    @event = Event.select_single({:event_id => @ver.event_id})
    @rec = Video_recording.select_single({:id => @ver.recording_id})
    @format = Video_target_format.select_single({:id => @vtf.target_format_id})
  end

  def vtf_rating
    write_row(Video_target_file, params[:video_target_file])
    redirect_to( :action => 'transcodings' )
  end

  def list_events
    @content_subtitle = local("video::list_events")
    @events = View_event.select({:conference_id => @current_conference.conference_id, :translated => @current_language}, {:order => [:conference_day, :start_time]})
  end

  def toggle_lock_recording
    vr = Video_recording.select_single({:id => params[:id], :conference_id => @current_conference.conference_id})
    raise "Locking unknown recording" if !vr
    claim_text = ""
    #lock
    if vr.locked_by == nil
      vr.locked_by = POPE.user.person_id
      claim_text = "Unclaim"
    #unlock
    elsif vr.locked_by == POPE.user.person_id or POPE.permission?('video_admin')
      vr.locked_by = nil
      claim_text = "Claim"
    else
      claim_text = "Error"
      return render_text(claim_text)
    end

    unless vr.write
      raise "Could not lock/unlock the recording"
    end
    return render_text(claim_text)
  end

  def toggle_lock_file
    vtf = Video_target_file.select_single({:id => params[:id]})
    raise "Locking unknown target file" if !vtf
    #lock
    if vtf.locked_by == nil
      vtf.locked_by = POPE.user.person_id
    #unlock
    elsif vtf.locked_by == POPE.user.person_id or POPE.permission?('video_admin')
      vtf.locked_by = nil
    else
      raise "Someone beat you to it"
    end
    vtf.write or raise "Could not lock the file"
    return redirect_to( :action => 'transcodings' )
  end

  def mark_for_deletion
     rec = Video_recording.select_single({:id => params[:id]})
     raise "Couldn't find what to delete" if !rec
     st = Video_file_status.select_single({:file_status_code => 'D'})
     rec.file_status_id = st.id
     rec.write or raise "Couldn't record the changes"
     redirect_to( :action => 'index' )
  end

  def save_current_conference
    POPE.user.current_conference_id = params[:conference_id]
    POPE.user.write
    redirect_to( request.env['HTTP_REFERER'] )
  end

  protected

  def init
    @content_title = 'Video'
    @current_conference = Conference.select_single(:conference_id => POPE.user.current_conference_id)
    @current_language = POPE.user.current_language
    @video_base = 'file:///video'
  end

  def check_recording_lock
    return false unless Video_recording.select_single({:id => params[:id]}).locked_by == POPE.user.person_id
    true
  end

  def check_target_file_lock
    if params[:video_target_file]
      id = params[:video_target_file][:id]
    elsif params[:id]
      id = params[:id]
    else
      return false
    end
    return false unless Video_target_file.select_single({:id => id}).locked_by == POPE.user.person_id
    true
  end

  def check_permission
    if POPE.permission?('video_login')
      return true
    end
    redirect_to(:controller=>'submission')
    false
  end

end
