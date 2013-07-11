class PentabarfController < ApplicationController

  before_filter :init
  before_filter :check_transaction, :only=>[:save_event,:save_person,:save_conference]
  around_filter :update_last_login, :except=>[:activity]
  around_filter :save_preferences, :only=>[:search_person_simple,:search_person_advanced,:search_event_simple,:search_event_advanced,:search_conference_simple]
  append_after_filter :set_content_type

  def conflicts
    @content_title = "Conflicts"
    @conflict_level = ['fatal','error','warning','note']
    conflicts = []
    conflicts += View_conflict_person.call({:conference_id => @current_conference.conference_id},{ :translated => @current_language})
    conflicts += View_conflict_event.call({:conference_id => @current_conference.conference_id},{ :translated => @current_language})
    conflicts += View_conflict_event_event.call({:conference_id => @current_conference.conference_id},{ :translated => @current_language})
    conflicts += View_conflict_event_person.call({:conference_id => @current_conference.conference_id},{ :translated => @current_language})
    conflicts += View_conflict_event_person_event.call({:conference_id => @current_conference.conference_id},{ :translated => @current_language})
    @conflicts = Hash.new do | k, v | k[v] = Array.new end
    conflicts.each do | c |
      next if not @conflict_level.member?( c.conflict_level )
      @conflicts[c.conflict_level] << c
    end
  end

  def conflict_event
    @conflicts = []
    @conflicts += View_conflict_event.call({:conference_id => @current_conference.conference_id},{:event_id=>params[:id],:translated=>@current_language})
    @conflicts += View_conflict_event_event.call({:conference_id => @current_conference.conference_id},{:event_id1=>params[:id],:translated=>@current_language})
    @conflicts += View_conflict_event_person.call({:conference_id => @current_conference.conference_id},{:event_id=>params[:id],:translated=>@current_language})
    @conflicts += View_conflict_event_person_event.call({:conference_id => @current_conference.conference_id},{:event_id1=>params[:id],:translated=>@current_language})
    @conflicts.length > 0 ? render( :partial => 'conflict_event' ) : render( :text => '' )
  end

  def conflict_person
    @conflicts = []
    @conflicts += View_conflict_person.call({:conference_id => @current_conference.conference_id},{:person_id=>params[:id],:translated=>@current_language})
    @conflicts += View_conflict_event_person.call({:conference_id => @current_conference.conference_id},{:person_id=>params[:id],:translated=>@current_language})
    @conflicts += View_conflict_event_person_event.call({:conference_id => @current_conference.conference_id},{:person_id=>params[:id],:translated=>@current_language})
    @conflicts.length > 0 ? render( :partial => 'conflict_person' ) : render( :text => '' )
  end

  def index
    @content_title = "Overview"
  end

  def own_events
    @content_title = "Own events"
  end

  ["event","person","conference"].each do | action |
    define_method("delete_#{action}") do
      row = action.capitalize.constantize.select_single("#{action}_id"=>params[:id])
      row.delete
      redirect_to(:action=>:index)
    end
  end

  def conference
    begin
      @conference = Conference.select_single( :conference_id => params[:id] )
      @content_title = @conference.title
    rescue
      raise "Not allowed to create conference." if not POPE.permission?( :create_conference )
      @content_title = "New Conference"
      return redirect_to(:action=>:conference,:id=>'new') if params[:id] != 'new'
      @conference = Conference.new(:conference_id=>0)
    end
    @transaction = Conference_transaction.select_single({:conference_id=>@conference.conference_id}) rescue Conference_transaction.new
  end

  def save_conference
    params[:conference][:conference_id] = params[:id] if params[:id].to_i > 0
    conf = write_row( Conference, params[:conference], {:except=>[:conference_id],:always=>[:f_submission_enabled,:f_visitor_enabled,:f_feedback_enabled,:f_reconfirmation_enabled]} )
    write_rows( Conference_day, params[:conference_day], {:preset=>{:conference_id => conf.conference_id},:always=>[:public],:ignore_empty=>:conference_day})
    write_rows( Conference_language, params[:conference_language], {:preset=>{:conference_id => conf.conference_id}})
    write_rows( Conference_team, params[:conference_team], {:preset=>{:conference_id => conf.conference_id}})
    write_rows( Conference_track, params[:conference_track], {:preset=>{:conference_id => conf.conference_id}})
    write_rows( Conference_room, params[:conference_room], {:preset=>{:conference_id => conf.conference_id},:always=>[:public]})
    write_rows( Conference_room_role, params[:conference_room_role], {:preset=>{:conference_id => conf.conference_id}})
    write_file_row( Conference_image, params[:conference_image], {:preset=>{:conference_id => conf.conference_id},:image=>true})
    Conference_transaction.new({:conference_id=>conf.conference_id,:changed_by=>POPE.user.person_id}).write

    redirect_to( :action => :conference, :id => conf.conference_id)
  end

  def event
    begin
      @event = Event.select_single( :event_id => params[:id] )
      @content_title = @event.title
      @content_subtitle = @event.subtitle
      @dc_event = DebConf::Dc_event.select_single({:event_id=>@event.event_id})
    rescue
      raise "Not allowed to create event." if not POPE.permission?( :create_event )
      return redirect_to(:action=>:event,:id=>'new') if params[:id] != 'new'
      @content_title = "New Event"
      @event = Event.new(:event_id=>0,:conference_id=>@current_conference.conference_id)
      @dc_event = DebConf::Dc_event.new({:event_id=>@event.event_id})
    end
    @event_rating = Event_rating.select_or_new({:event_id=>@event.event_id,:person_id=>POPE.user.person_id})
    @conference = Conference.select_single( :conference_id => @event.conference_id )
    @current_conference = @conference
    @attachments = View_event_attachment.select({:event_id=>@event.event_id,:translated=>@current_language})
    @transaction = Event_transaction.select_single({:event_id=>@event.event_id}) rescue Event_transaction.new
  end

  def save_event
    params[:event][:event_id] = params[:id] if params[:id].to_i > 0
    event = write_row( Event, params[:event], {:except=>[:event_id,:conference_id],:init=>{:conference_id=>@current_conference.conference_id},:always=>[:public]} )
    write_row( Event_rating, params[:event_rating], {:preset=>{:event_id => event.event_id,:person_id=>POPE.user.person_id}})
    write_rows( Event_person, params[:event_person], {:preset=>{:event_id => event.event_id}})
    write_rows( Event_link, params[:event_link], {:preset=>{:event_id => event.event_id},:ignore_empty=>:url})
    write_rows( Event_link_internal, params[:event_link_internal], {:preset=>{:event_id => event.event_id},:ignore_empty=>:url})
    write_file_row( Event_image, params[:event_image], {:preset=>{:event_id => event.event_id},:image=>true})
    write_rows( Event_attachment, params[:event_attachment], {:always=>[:public]} )
    write_file_rows( Event_attachment, params[:attachment_upload], {:preset=>{:event_id=>event.event_id}})

    write_row(DebConf::Dc_event, params[:dc_event], {:preset=>{:event_id => event.event_id}})

    Event_transaction.new({:event_id=>event.event_id,:changed_by=>POPE.user.person_id}).write

    redirect_to( :action => :event, :id => event.event_id )
  end

  def person
    begin
      @person = Person.select_single( :person_id => params[:id] )
      @content_title = @person.name
    rescue
      raise "Not allowed to create person." if not POPE.permission?( :create_person )
      return redirect_to(:action=>:person,:id=>'new') if params[:id] != 'new'
      @content_title = "New Person"
      @person = Person.new(:person_id=>0)
    end
    @conference = @current_conference
    @conference_person = Conference_person.select_or_new({:conference_id=>@conference.conference_id, :person_id=>@person.person_id})
    @conference_person_travel = Conference_person_travel.select_or_new({:conference_person_id=>@conference_person.conference_person_id.to_i})
    @person_rating = Person_rating.select_or_new({:person_id=>@person.person_id,:evaluator_id=>POPE.user.person_id})
    @person_image = Person_image.select_or_new({:person_id=>@person.person_id})
    @account = Account.select_or_new(:person_id=>@person.person_id)
    @account_roles = @account.new_record? ? [] : Account_role.select(:account_id=>@account.account_id)
    @transaction = Person_transaction.select_single({:person_id=>@person.person_id}) rescue Person_transaction.new
    @dc_conference_person = DebConf::Dc_conference_person.select_or_new({:conference_id=>@conference.conference_id, :person_id=>@person.person_id})
    @dc_person = DebConf::Dc_person.select_or_new({:person_id=>@person.person_id})
  end

  def save_person
    params[:person][:person_id] = params[:id] if params[:id].to_i > 0
    person = write_row( Person, params[:person], {:except=>[:person_id],:always=>[:spam]} )
    if params[:account] || POPE.permission?( :modify_account )
      params[:account][:account_id] = Account.select_single(:person_id=>person.person_id).account_id rescue nil
      account = write_row( Account, params[:account], {:except=>[:account_id,:password,:password2],:preset=>{:person_id=>person.person_id},:ignore_empty=>:login_name} ) do | row |
        if params[:account][:password].to_s != "" && ( row.account_id == POPE.user.account_id || POPE.permission?( :modify_account ) )
          raise "Passwords do not match" if params[:account][:password] != params[:account][:password2]
          row.password = params[:account][:password]
        end
      end
    end
    options = {:preset=>{:person_id => person.person_id,:conference_id=>@current_conference.conference_id}}
    conference_person = write_row( Conference_person, params[:conference_person], {:always=>[:arrived,:reconfirmed],:preset=>{:person_id => person.person_id,:conference_id=>@current_conference.conference_id}})
    write_row( Conference_person_travel, params[:conference_person_travel], {:preset=>{:conference_person_id => conference_person.conference_person_id},
                 :always=>[:need_travel_cost]})
    write_row( Person_rating, params[:person_rating], {:preset=>{:person_id => person.person_id,:evaluator_id=>POPE.user.person_id}})
    write_rows( Person_language, params[:person_language], {:preset=>{:person_id => person.person_id}})
    write_rows( Conference_person_link, params[:conference_person_link], {:preset=>{:conference_person_id => conference_person.conference_person_id},:ignore_empty=>:url})
    write_rows( Conference_person_link_internal, params[:conference_person_link_internal], {:preset=>{:conference_person_id => conference_person.conference_person_id},:ignore_empty=>:url})
    write_rows( Person_im, params[:person_im], {:preset=>{:person_id => person.person_id},:ignore_empty=>:im_address})
    write_rows( Person_phone, params[:person_phone], {:preset=>{:person_id => person.person_id},:ignore_empty=>:phone_number})
    write_rows( Event_person, params[:event_person], {:preset=>{:person_id => person.person_id}})

    dc_options = {:preset=>{:person_id => person.person_id,:conference_id=>@current_conference.conference_id},
      :always=>[:assassins,:public_data,:proceedings,:attend,:travel_to_venue,:has_to_pay,:has_paid,:travel_from_venue,:coffee_mug,:camping,:com_accom,:whyrequest,:debconfbenefit,:debianwork]}
    write_row(DebConf::Dc_conference_person, params[:dc_conference_person], dc_options)
    write_row(DebConf::Dc_person, params[:dc_person], {:preset=>{:person_id => person.person_id}})

    write_file_row( Person_image, params[:person_image], {:preset=>{:person_id => person.person_id},:always=>[:public],:image=>true})
    write_person_availability( @current_conference, person, params[:person_availability])

    if POPE.permission?(:modify_account)
      params[:account_role].each do | k,v | v[:remove] = true if not v[:set] end
      write_rows( Account_role, params[:account_role], {:preset=>{:account_id=>account.account_id},:except=>[:set]})
    end
    Person_transaction.new({:person_id=>person.person_id,:changed_by=>POPE.user.person_id}).write

    redirect_to( :action => :person, :id => person.person_id )
  end

  def activity
    @last_active = View_last_active.select( {:login_name => {:ne => POPE.user.login_name}}, {:limit => 12} )
    render(:partial=>'activity')
  end

  def recent_changes
    @content_title = "Recent Changes"
    @changes = View_recent_changes.select( {}, {:limit => 25 } )
  end

  def schedule
    @content_title = 'Schedule'
    @events = View_schedule.select({:conference_id => @current_conference.conference_id, :translated => @current_language})
  end

  def find_person
    @content_title = "Find Person"
  end

  def search_person_simple
    query = params[:id] ? @preferences[:search_person_simple].to_s : params[:search_person_simple].to_s
    conditions = {}
    conditions[:conference_id] = @current_conference.conference_id
    conditions[:AND] = []
    query.split(/ +/).each do | word |
      cond = {}
      [:first_name,:last_name,:nickname,:public_name,:email].each do | field |
        cond[field] = {:ilike=>"%#{word}%"}
      end
      conditions[:AND] << {:OR=>cond}
    end
    @results = DebConf::Dc_view_find_person.select( conditions, {:distinct => :person_id} )
    @preferences[:search_person_simple] = query
    render(:partial=>'search_person')
  end

  def search_person_advanced
    params[:search_person] = @preferences[:search_person_advanced] if params[:id]
    conditions = form_to_condition( params[:search_person], DebConf::Dc_view_find_person )
    @results = DebConf::Dc_view_find_person.select( conditions, {:distinct=>:person_id})
    @preferences[:search_person_advanced] = params[:search_person]
    render(:partial=>'search_person')
  end

  def find_event
    @content_title = "Find Event"
  end

  def search_event_simple
    conditions = {}
    conditions[:conference_id] = @current_conference.conference_id
    conditions[:translated] = @current_language
    query = params[:id] ? @preferences[:search_event_simple].to_s : params[:search_event_simple].to_s
    conditions[:AND] = []
    query.split(/ +/).each do | word |
      cond = {}
      [:title,:subtitle].each do | field |
        cond[field] = {:ilike=>"%#{word}%"}
      end
      conditions[:AND] << {:OR=>cond}
    end
    @results = View_find_event.select( conditions )
    @preferences[:search_event_simple] = query
    render(:partial=>'search_event')
  end

  def search_event_advanced
    params[:search_event] = @preferences[:search_event_advanced] if params[:id]
    conditions = form_to_condition( params[:search_event], View_find_event )
    conditions[:conference_id] = @current_conference.conference_id
    conditions[:translated] = @current_language
    @results = View_find_event.select( conditions )
    @preferences[:search_event_advanced] = params[:search_event]
    render(:partial=>'search_event')
  end

  def find_conference
    @content_title = "Find Conference"
  end

  def search_conference_simple
    conditions = {}
    query = params[:id] ? @preferences[:search_conference_simple].to_s : params[:search_conference_simple].to_s
    if not query.empty?
      conditions[:AND] = []
      query.split(/ +/).each do | word |
        cond = {}
        [:acronym,:title,:subtitle].each do | field |
          cond[field] = {:ilike=>"%#{word}%"}
        end
        conditions[:AND] << {:OR=>cond}
      end
    end
    @results = View_find_conference.select( conditions )
    @preferences[:search_conference_simple] = query
    render(:partial=>'search_conference_simple')
  end

  def save_current_conference
    POPE.user.current_conference_id = params[:conference_id]
    POPE.user.write
    redirect_to( request.env['HTTP_REFERER'] ? request.env['HTTP_REFERER'] : url_for(:controller=>'pentabarf',:action=>:index) )
  end

  def mail
    @content_title = 'Mail'
    @recipients = [['speaker', 'All accepted speakers of this conference'],
                   ['reviewer', 'All persons with the role reviewer'],
                   ['missing_slides', 'Missing Slides'],
                   ['all_speaker', 'All speakers of all conferences']]
  end

  def recipients
    return render_text('') unless params[:id]
    person_ids = []
    @recipients = []
    recipient_members( params[:id] ).each do | r |
      if not person_ids.member?( r.person_id )
        person_ids << r.person_id
        @recipients << r
      end
    end
    render(:partial=>'recipients')
  end

  def send_mail
    raise Pope::PermissionError, 'not allowed to send mail.' unless POPE.permission?('admin_login')
    from = @current_conference.email 
    variables = ['email','name','person_id','conference_acronym','conference_title']
    if params[:mail][:recipients]
      recipients = recipient_members( params[:mail][:recipients])
      person_ids = recipients.map(&:person_id).uniq
      person_ids.each do | person_id |
        events = recipients.select{|recipient| recipient.person_id == person_id}
        r = events[0]
        titles = []
        events.each do | event |
          titles.push( event.event_title )
        end if r.respond_to?(:event_title)
        body = params[:mail][:body].dup
        subject = params[:mail][:subject].dup
        variables.each do | v |
          body.gsub!(/\{\{#{v}\}\}/i, r[v].to_s)
          subject.gsub!(/\{\{#{v}\}\}/i, r[v].to_s)
        end
        body.gsub!(/\{\{event_title\}\}/i, events.join(','))
        subject.gsub!(/\{\{event_title\}\}/i, events.join(','))
        Notifier::deliver_general(r.email, subject, body, from)
      end
    end
    redirect_to(:action=>:mail)
  end

  protected

  def init
    # Set the symbolic @thisconf variable, to avoid filling the views
    # with meaningless numeric comparisons.
    # We started using Pentabarf for Edinburgh - which got conference_id == 1.
    confs = [nil, :edinburgh, :argentina, :caceres, :nyc, :bosnia, :managua, :swiss]

    @current_conference = Conference.select_single(:conference_id => POPE.user.current_conference_id) rescue Conference.new(:conference_id=>0)
    @preferences = POPE.user.preferences
    @current_language = POPE.user.current_language || 'en'
    @thisconf = confs[@current_conference.conference_id]
  end

  def check_permission
    if POPE.permission?('pentabarf_login')
      return true
    end
    redirect_to(:controller=>'submission')
    false
  end

  def save_preferences
    yield
    POPE.user.preferences = @preferences
  end

  def set_content_type
    # FIXME: jscalendar does not work with application/xml
    response.headers['Content-Type'] = 'text/html'
  end

  # converts values submitted by advanced search to a hash understood by momomoto
  def form_to_condition( params, klass )
    conditions = Hash.new{|h,k|
      if klass.columns[k].kind_of?( Momomoto::Datatype::Text )
        key = :ilike
      else
        key = :eq
      end
      h[k]={key=>[]}
    }
    params.each do | key, value |
      field = value[:key].to_sym
      if klass.columns[field].kind_of?( Momomoto::Datatype::Text )
        conditions[field][:ilike] << "%#{value[:value]}%"
      else
        conditions[field][:eq] << value[:value]
      end
    end
    conditions
  end

  def recipient_members( name )
    case name
      when 'all_speaker' then View_mail_all_speaker.select({},{:order=>Momomoto.lower(:name)})
      when 'reviewer' then View_mail_all_reviewer.select({},{:order=>Momomoto.lower(:name)})
      when 'speaker' then View_mail_accepted_speaker.select({:conference_id => @current_conference.conference_id},{:order=>Momomoto.lower(:name)})
      when 'missing_slides' then View_mail_missing_slides.select({:conference_id => @current_conference.conference_id},{:order=>Momomoto.lower(:name)})
      else raise 'Unknown recipient tag'
    end
  end

end

