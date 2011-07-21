class EntranceController < ApplicationController

  before_filter :init

  def index
    @content_title = "Front Desk"
    @content_subtitle = "Search Person"
  end

  def save_current_conference
    POPE.user.current_conference_id = params[:conference_id]
    POPE.user.write
    redirect_to( request.env['HTTP_REFERER'] ? request.env['HTTP_REFERER'] : url_for(:controller=>'entrance',:action=>:index) )
  end

  def search_person
    query = params[:id] ? @preferences[:entrance_search_person].to_s : params[:entrance_search_person].to_s
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
    cond2 = {}
    cond2[:reconfirmed] = true
    cond2[:arrived] = false
    conditions[:AND] << {:AND => cond2 } 
    @results = DebConf::Dc_view_find_person_entrance.select( conditions, {:distinct => [:name,:person_id]} )
    @preferences[:entrance_search_person] = query
    render(:partial=>'search_person')
  end

  def person
    @conference_person = DebConf::Dc_view_find_person_entrance.select_single( :person_id => params[:id], :conference_id => @current_conference.conference_id)
    @dc_conference_person = DebConf::Dc_conference_person.select_or_new({:conference_id=>@current_conference.conference_id, :person_id => params[:id]})
    @content_title = "Front Desk"
    @content_subtitle = "Person View"
  end

  def save_person
    dcp = [:badge, :foodtickets, :has_to_pay, :has_paid, :shirt, :bag, :proceedings, :proceeded, :amount_to_pay, :paiddaytrip, :has_sim_card]
    dcpv = Hash.new
    dcp.each do |field|
      dcpv[field] = params[:dc_view_find_person_entrance][field] || 'f'
    end
#    if @this_conference == :bosnia
#      dcpv[:has_sim_card] = params[:dc_conference_person][:has_sim_card] || 'f'
#      raise Exception, dcpv.to_yaml if params[:dc_view_find_person_entrance].person_id=120
#    end

    options = params[:dc_view_find_person_entrance]
    write_row( DebConf::Dc_conference_person, dcpv, {:preset => {:conference_id => @current_conference.conference_id, :person_id => options[:person_id] } } )
    write_row( Conference_person, {:arrived => options[:arrived]}, { :preset => {:conference_id => @current_conference.conference_id, :person_id => options[:person_id], :conference_person_id => options[:conference_person_id] } } )

    redirect_to( :controller => 'entrance')
  end

  def confirm_person
    conf_fields = [:person_id, :conference_person_id, :arrived, :conference_id]
    conference_person = Conference_person.select_or_new({:conference_id => @current_conference.conference_id, :person_id => params[:id]})
    dc_conference_person = DebConf::Dc_conference_person.select_or_new({:conference_id => @current_conference.conference_id, :person_id => params[:id]})

    conf ={}
    conf[:reconfirmed] = true
    conf_fields.each do |field|
      conf[field] = conference_person[field]
    end

    dc_conf_fields = [:person_id, :conference_id]
    dc_conf = {}
    dc_conf[:attend] = true

    dc_conf_fields.each do |field|
      dc_conf[field] = dc_conference_person[field]
    end

    write_row( Conference_person, conf,:presets => {:person_id => params[:id], :conference_id => @current_conference.conference_id} )
    write_row( DebConf::Dc_conference_person, dc_conf,:presets => {:person_id => params[:id], :conference_id => @current_conference.conference_id} )
    redirect_to( :action => 'person', :id => params[:id])
  end

  def not_reconfirmed
     @content_title = "Front Desk"
     @content_subtitle = "Unreconfirmed Users"
#    render(:partial=>'not_reconfirmed')
  end

  def arrived
    @content_title = "Front Desk"
    @content_subtitle = "Search Arrived Person"
  end

  def search_arrived
    query = params[:id] ? @preferences[:entrance_search_arrived].to_s : params[:entrance_search_arrived].to_s
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
    cond2 = {}
    cond2[:reconfirmed] = true
    cond2[:arrived] = true
    conditions[:AND] << {:AND => cond2 } 
    @results = DebConf::Dc_view_find_person_entrance.select( conditions, {:distinct => [:name,:person_id]} )
    @preferences[:entrance_search_arrived] = query
    render(:partial=>'search_arrived')
  end

  def wat
    @wat = DebConf::Dc_view_person_not_arrived.select
    @content_title = "Front Desk"
    @content_subtitle = "Where Are They?"
  end

  def not_reconfirmed_side
    query = params[:id] ? @preferences[:entrance_find_unreconfirmed_person].to_s : params[:entrance_not_reconfirmed_side].to_s
    conditions = {}
    #conditions[:conference_id] = @current_conference.conference_id
    conditions[:AND] = []
    query.split(/ +/).each do | word |
      cond = {}
      [:first_name,:last_name,:nickname,:public_name,:email].each do | field |
        cond[field] = {:ilike=>"%#{word}%"}
      end
      conditions[:AND] << {:OR=>cond}
    end
    @preferences[:entrance_find_unreconfirmed_person] = query
    @unreconfirmed = DebConf::Dc_view_find_person_is_an_idiot.select( conditions )
    render(:partial=>'not_reconfirmed_side')
  end

  def arrivals_by_date
    @dates = {}
    DebConf::Dc_when_do_they_get_here.select().each do |arrival|
      if not @dates["#{arrival[:arrival_date]}"].kind_of? Array
        @dates["#{arrival[:arrival_date]}"] = Array.new
      end
      @dates["#{arrival[:arrival_date]}"] << arrival
    end
    @content_title = "Front Desk"
    @content_subtitle = "Arrivals By Date"
  end

  protected

  def init
    # Set the symbolic @thisconf variable, to avoid filling the views
    # with meaningless numeric comparisons.
    # We started using Pentabarf for Edinburgh - which got conference_id == 1.
    confs = [nil, :edinburgh, :argentina, :caceres, :nyc, :bosnia]

    @current_conference = Conference.select_single(:conference_id => POPE.user.current_conference_id) rescue Conference.new(:conference_id=>0)
    @preferences = POPE.user.preferences
    @current_language = POPE.user.current_language || 'en'
    @thisconf = confs[@current_conference.conference_id]
  end

  def check_permission
    POPE.permission?('entrance_login')
  end

end
