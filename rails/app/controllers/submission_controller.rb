# -*- coding: utf-8 -*-
class SubmissionController < ApplicationController

  before_filter :init
  before_filter :check_transaction, :only=>[:save_event]
  after_filter :set_content_type

  def index
    @conferences = Conference.select({:f_submission_enabled=>'t'})
  end

  def attendee
  @content_title = "Attendee list sorted by name"
  end

  def attendee_time
  @content_title = "Attendee list sorted by arrival time"
  end

  def attendee_dep
  @content_title = "Attendee list sorted by departure time"
  end

  def rooms
  @content_title = "Rooms"
  end

  def login
    redirect_to(:action=>:index,:id=>'auth')
  end

  def event
    if params[:id] && params[:id] != 'new'
      own = Own_conference_events.call({:person_id=>POPE.user.person_id,:conference_id=>@conference.conference_id},{:own_conference_events=>params[:id]})
      raise "You are not allowed to edit this event." if own.length != 1
      @event = Event.select_single({:event_id=>params[:id]})
      @dc_event = DebConf::Dc_event.select_single({:event_id=>@event.event_id})
    else
      @event = Event.new({:conference_id=>@conference.conference_id,:event_id=>0})
      @dc_event = DebConf::Dc_event.new({:event_id=>@event.event_id})
    end
    @attachments = View_event_attachment.select({:event_id=>@event.event_id,:translated=>@current_language})
    @transaction = Event_transaction.select_single({:event_id=>@event.event_id}) rescue Event_transaction.new
  end

  def events
    own_events = Own_conference_events.call(:conference_id=>@conference.conference_id,:person_id=>POPE.user.person_id)
    own_events = own_events.map{|e| e.own_conference_events }
    if own_events.length > 0
      @events = View_event.select(:event_id=>own_events,:translated=>@current_language,:conference_id=>@conference.conference_id)
    else
      @events = []
    end
  end

  def save_event
    raise "Event title is mandatory" if params[:event][:title].empty?
    if params[:id].to_i == 0
      event = Submit_event.call(:e_person_id=>POPE.user.person_id,:e_conference_id=>@conference.conference_id,:e_title=>params[:event][:title])
      params[:id] = event[0].submit_event
      POPE.refresh
    end
    params[:event][:event_id] = params[:id]
    event = write_row( Event, params[:event], {:except=>[:event_id],:only=>Event::SubmissionFields} )
    write_rows( Event_link, params[:event_link], {:preset=>{:event_id => event.event_id},:ignore_empty=>:url})
    write_file_row( Event_image, params[:event_image], {:preset=>{:event_id => event.event_id},:image=>true})
    write_rows( Event_attachment, params[:event_attachment], {:always=>[:public]} )
    write_file_rows( Event_attachment, params[:attachment_upload], {:preset=>{:event_id=>event.event_id}})

    write_row(DebConf::Dc_event, params[:dc_event], {:preset=>{:event_id => event.event_id}})

    Event_transaction.new({:event_id=>event.event_id,:changed_by=>POPE.user.person_id}).write

    redirect_to( :action => :event, :id => event.event_id )
  end

  def all_events
    @events = View_submission_event.select({:conference_id=>@conference.conference_id,:translated=>@current_language},{:order=>[:title,:subtitle]})
    @content_title = "- All submitted Events"
  end

  def person
    @person = Person.select_single(:person_id=>POPE.user.person_id)
    @account = Account.select_or_new(:person_id=>@person.person_id)
    @current_conference = @conference
    @conference_person = Conference_person.select_or_new({:conference_id=>@conference.conference_id, :person_id=>@person.person_id})
    @conference_person_travel = Conference_person_travel.select_or_new({:conference_person_id=>@conference_person.conference_person_id.to_i})
    @person_image = Person_image.select_or_new({:person_id=>@person.person_id})
    @transaction = Person_transaction.select_single({:person_id=>@person.person_id}) rescue Person_transaction.new
    @dc_person = DebConf::Dc_person.select_or_new({:person_id=>@person.person_id})
    @dc_conference_person = DebConf::Dc_conference_person.select_or_new({:conference_id=>@conference.conference_id, :person_id=>@person.person_id})
  end

  def save_person
    old_conference_person = Conference_person.select_or_new({:conference_id=>@conference.conference_id, :person_id=>POPE.user.person_id})
    old_dc_conference_person = DebConf::Dc_conference_person.select_or_new({:conference_id=>@conference.conference_id, :person_id=>POPE.user.person_id})
    old_conference_person_travel = Conference_person_travel.select_or_new({:conference_person_id=>params[:conference_person][:conference_person_id].to_i})

    # if ["1", "2", "3", "4", "5"].include?(params[:dc_conference_person][:dc_participant_category_id])
    #   if not ["1", "2", "3", "4", "5"].include?(old_dc_conference_person.dc_participant_category_id)
    #     params[:dc_conference_person][:dc_participant_category_id] = old_dc_conference_person.dc_participant_category_id
    #   end
    # elsif ["6", "7", "8", "9", "10", "11", "12"].include?(params[:dc_conference_person][:dc_participant_category_id])
    #   if not ["6", "7", "8", "9", "10", "11", "12"].include?(old_dc_conference_person.dc_participant_category_id)
    #     params[:dc_conference_person][:dc_participant_category_id] = old_dc_conference_person.dc_participant_category_id
    #   end
    # elsif ["58", "59", "60", "61", "62"].include?(params[:dc_conference_person][:dc_participant_category_id])
    #   if not [58, 59, 60, 61, 62].include?(old_dc_conference_person.dc_participant_category_id)
    #     raise "The deadline to increase your sponsorship request was April 15, so your changes were not accepted."
    #   end
    # elsif ["66", "67", "68", "69", "70"].include?(params[:dc_conference_person][:dc_participant_category_id])
    #   if not [58, 59, 60, 61, 62, 66, 67, 68, 69, 70].include?(old_dc_conference_person.dc_participant_category_id)
    #     raise "The deadline to increase your sponsorship request was April 15, so your changes were not accepted."
    #   end
    # elsif ["71", "72", "73", "74", "75"].include?(params[:dc_conference_person][:dc_participant_category_id])
    #   if not [58, 59, 60, 61, 62, 71, 72, 73, 74, 75].include?(old_dc_conference_person.dc_participant_category_id)
    #     raise "The deadline to increase your sponsorship request was April 15, so your changes were not accepted."
    #   end
    # elsif ["28", "29", "30", "31", "32", "33", "34", "35"].include?(params[:dc_conference_person][:dc_participant_category_id])
    #   params[:dc_conference_person][:food_id] = "18"
    # end

    # if params[:dc_conference_person][:accom_id] == "12"
    #     if not old_dc_conference_person.accom_id == 12
    #       raise "The deadline to request on-campus lodging was July 6, so your changes were not accepted."
    #     end
    # end

    # if params[:conference_person_travel][:arrival_date] != old_conference_person_travel.arrival_date.to_s or params[:conference_person_travel][:departure_date] != old_conference_person_travel.departure_date.to_s
    #     if params[:dc_conference_person][:accom_id] == "12" or ["58", "59", "60", "61", "62", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75"].include?(params[:dc_conference_person][:dc_participant_category_id])
    #       raise "The deadline for on-campus or sponsored attendees to change dates was July 6, so your changes were not accepted. Contact registration@debconf.org if changes are needed."
    #     end
    # end

    # if params[:dc_conference_person][:food_id] == "18" or params[:dc_conference_person][:accom_id] == "11"
    #   params[:dc_conference_person][:accom_id] = "11"
    #   params[:dc_conference_person][:food_id] = "18"
    #   map_id = DebConf::DC_participant_mapping.select_single({:participant_category_id=>5, :person_type_id=>params[:dc_conference_person][:person_type_id]})
    #   params[:dc_conference_person][:dc_participant_category_id]= map_id.participant_mapping_id
    # end

    if params[:conference] == "dc13"
      # Sponsored registration from DC13: participant_mapping_id
      # (debconf.dc_participant_mapping) where participant_category in (26)
      # and conference_id=6
      sponsored = [232, 233, 234]

      # # Basic registration means no regular room will be provided
      # basic = [110, 111, 112, 113, 114, 115, 116, 117]
      # if params[:dc_conference_person][:accom_id] == '15'
      #   if basic.include? params[:dc_conference_person][:dc_participant_category_id].to_i
      #     raise 'Your requested category («Basic registration») is incompatible with ' +
      #       '«Regular» accomodation. Please fix it!'
      #   end
      # else
      #   if sponsored.include? params[:dc_conference_person][:dc_participant_category_id].to_i
      #     raise 'Your requested category («Sponsored») is incompatible with ' +
      #       'accomodations other than «Regular». Please fix it!'
      #   end
      # end

      # No more Sponsored Accomodation accepted after May 19 23:59
      if sponsored.include?(params[:dc_conference_person][:dc_participant_category_id].to_i) and
          !sponsored.include?(old_dc_conference_person.dc_participant_category_id.to_i) and
          Time.now > Time.gm(2014,5,19)
          raise "The deadline for sponsored attendees' registration was May 19, so your changes were not accepted. Contact registration@debconf.org if changes are needed."
      end

      # No more Sponsored food accepted after May 19 23:59
      if (params[:dc_conference_person][:food_select].to_i == 2) and
          (old_dc_conference_person.food_select.to_i != 2) and
        Time.now > Time.gm(2014,5,19)
        raise "The deadline for sponsored attendees' registration was May 19, so your changes to your food selection were not accepted. Contact registration@debconf.org if changes are needed."
      end

      # Enabling the "reconfirmed" checkbox requires dates to be
      # entered.  Checking whether the dates are valid will be left to
      # the client-side JS (and that allows admins to enter
      # nonstandard dates, were it to be needed)
      if params[:conference_person][:reconfirmed]
        arrive_date = params[:conference_person_travel][:arrival_date]
        depart_date = params[:conference_person_travel][:departure_date]
        if arrive_date.nil? or arrive_date.empty? or
            depart_date.nil? or depart_date.empty?
          raise 'You have marked your presence in Debconf as "Reconfirmed" (in the "General" tab).' + "\n" +
            'In order to accept the reconfirmation, we need you to enter arrival and departure dates (in the "Travel" tab).'
        end
      end

      # if params[:dc_conference_person][:debcamp_id].to_i == 2 and old_dc_conference_person.debcamp_id != 2
      #   raise "It's too late to register a plan for DebCamp — Sorry. You can still attend unsponsored, though"
      # end

      # Reconfirm period
      # if Date.today > Date.parse('2013-06-20')
      #   old_arr_date = old_conference_person_travel.arrival_date
      #   arr_date = Date.parse(params[:conference_person_travel][:arrival_date])
      #   old_dep_date = old_conference_person_travel.departure_date
      #   dep_date = Date.parse(params[:conference_person_travel][:departure_date])

      #   if (old_arr_date and arr_date != old_arr_date) or
      #       (old_dep_date and dep_date != old_dep_date)
      #     raise 'Reconfirmation period is over - You cannot change arrival/departure dates anymore! ' +
      #       'Please mail registration@debconf.org to let them know your new travel plans.'
      #   end
      # end

      # # Regular rooms cannot be accepted anymore after July 3 for
      # # those not yet having it
      # if Time.now > Time.gm(2011,7,3) and params[:dc_conference_person][:accom_id] == '15' and
      #     !(old_dc_conference_person.accom_id == 15)
      #   raise "We are sorry, you cannot select 'regular room' anymore. Please set your accomodation to 'I will arrange my own accommodation' and try again. Please mail registration@debconf.org if you need to make changes."
      # end

      # # People lodging at the hotel should not change their
      # # arrival/departure dates anymore (also, retroactively since
      # # July 3 :-P )
      # if Time.now > Time.gm(2011,7,3) and params[:dc_conference_person][:accom_id] == '15' and
      #     (old_conference_person_travel[:arrival_date].to_s != params[:conference_person_travel][:arrival_date]) or
      #     (old_conference_person_travel[:departure_date].to_s != params[:conference_person_travel][:departure_date])
      #   raise 'Hey, hey, not so fast! You cannot change your arrival/departure dates anymore. Please contact registration@debconf.org if you need to make changes.'
      # end
    end

    params[:person][:person_id] = POPE.user.person_id
    person = write_row( Person, params[:person], {:except=>[:person_id],:always=>[:spam]} )
    params[:account][:account_id] = Account.select_single(:person_id=>person.person_id).account_id rescue nil
    account = write_row( Account, params[:account], {:only=>[:current_language],:preset=>{:person_id=>person.person_id}} ) do | row |
      if params[:account][:password].to_s != ""
        raise "Passwords do not match" if params[:account][:password] != params[:account][:password2]
        row.password = params[:account][:password]
      end
    end
    options = {:preset=>{:person_id => person.person_id,:conference_id=>@conference.conference_id}}
    options[ @conference.f_reconfirmation_enabled ? :always : :except ] = [:reconfirmed]
    conference_person = write_row( Conference_person, params[:conference_person], options )
    POPE.refresh
    params[:conference_person_travel][:arrival_transport] ||= "ufo"
    params[:conference_person_travel][:departure_transport] ||= "ufo"
    write_row( Conference_person_travel, params[:conference_person_travel], {:preset=>{:conference_person_id => conference_person.conference_person_id},
                 :always=>[:need_travel_cost]})
    write_rows( Person_language, params[:person_language], {:preset=>{:person_id => person.person_id}})
    write_rows( Conference_person_link, params[:conference_person_link], {:preset=>{:conference_person_id => conference_person.conference_person_id},:ignore_empty=>:url})
    write_rows( Person_im, params[:person_im], {:preset=>{:person_id => person.person_id},:ignore_empty=>:im_address})
    write_rows( Person_phone, params[:person_phone], {:preset=>{:person_id => person.person_id},:ignore_empty=>:phone_number})

    dc_options = {:preset=>{:person_id => person.person_id,:conference_id=>@conference.conference_id},
      :always=>[:assassins,:public_data,:proceedings,:attend,:travel_to_venue,:travel_from_venue,:disabilities]}
    write_row(DebConf::Dc_conference_person, params[:dc_conference_person], dc_options)
    write_row(DebConf::Dc_person, params[:dc_person], {:preset=>{:person_id => person.person_id}})

    write_file_row( Person_image, params[:person_image], {:preset=>{:person_id => person.person_id},:always=>[:public],:image=>true})
    write_person_availability( @conference, person, params[:person_availability])

    Person_transaction.new({:person_id=>person.person_id,:changed_by=>POPE.user.person_id}).write

    redirect_to( :action => :person )
  end

  protected

  def init
    # Set the symbolic @thisconf variable, to avoid filling the views
    # with meaningless numeric comparisons.
    # We started using Pentabarf for Edinburgh - which got conference_id == 1.
    confs = [nil, :edinburgh, :argentina, :caceres, :nyc, :bosnia, :managua, :swiss]

    @current_language = POPE.user ? POPE.user.current_language : 'en'
    begin
      @conference = Conference.select_single(:acronym=>params[:conference],:f_submission_enabled=>'t')
      @thisconf = confs[@conference.conference_id]
    rescue Momomoto::Error
      if params[:action] != 'index' || params[:conference]
        redirect_to(:controller=>'submission', :action => :index, :conference => nil )
        return false
      end
    end
  end

  def auth
    return super if params[:action] != 'index' || params[:id] == 'auth'
    true
  end

  def check_permission
    POPE.permission?('submission_login')
  end

  def set_content_type
    # FIXME: jscalendar does not work with application/xml
    response.headers['Content-Type'] = 'text/html'
  end

end
