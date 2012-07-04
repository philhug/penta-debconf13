class AssassinsController < ApplicationController

  before_filter :init

  def save_current_conference
    POPE.user.current_conference_id = params[:conference_id]
    POPE.user.write
    redirect_to( request.env['HTTP_REFERER'] ? request.env['HTTP_REFERER'] : url_for(:controller=>'assassins',:action=>:index) )
  end

  def index
    @content_title = "Assassins"
    @content_subtitle = "The hunt is on!"
    @target = []
    @killed = []
    @not_playing = []
    begin
      assassins = DebConf::Dc_conference.select_single({:conference_id => @current_conference.conference_id})
    rescue
      return redirect_to( :action => :have_patience)
    end
    if assassins.assassins_started == false
      return redirect_to( :action => :have_patience)
    end
                                                         
    begin
      @killed = DebConf::Dc_assassins_kills.select_single({:conference_id => @current_conference.conference_id, 
                                                           :person_id => POPE.user.person_id})
    rescue Momomoto::Nothing_found
      begin
        @not_playing = DebConf::View_dc_assassins.select_single({:conference_id => @current_conference.conference_id, 
                                                                 :person_id => POPE.user.person_id})
      rescue Momomoto::Nothing_found
        return true
      end
    end

    if @killed.class == Array
      if assassins.assassins_ended == true
        return redirect_to( :action => :winners )
      end
      person = DebConf::Dc_assassins.select_single({:conference_id => @current_conference.conference_id, 
                                                    :person_id => POPE.user.person_id})
      @target = DebConf::View_dc_assassins.select_single({:conference_id => @current_conference.conference_id, 
                                                          :person_id => person.target_id})
      @pending = false
      begin
        killed_off = DebConf::Dc_assassins_kills.select_single({:conference_id => @current_conference.conference_id, 
                                                                :person_id => person.target_id, :killed_by => POPE.user.person_id})
        @pending = true
        @content_subtitle = "Waiting for confirmation"
      rescue Momomoto::Nothing_found
      end
      @victims = DebConf::View_dc_assassination_victims.select({:conference_id => @current_conference.conference_id, 
                                                                :acked_kill => true,
                                                                :killed_by => POPE.user.person_id}, 
                                                               {:ignore_empty => true})
    else
      if @killed.acked_kill == false
        @killer = DebConf::View_dc_assassins.select_single({:conference_id => @current_conference.conference_id, 
                                                            :person_id => @killed.killed_by, })
        return redirect_to( :action => :confirm_kill )
      elsif @killed.acked_kill == true
        if assassins.assassins_ended == true
          return redirect_to( :action => :winners )
        end
        return redirect_to( :action => :already_killed )
      end
    end

  end

  def target_killed
    foo = DebConf::Dc_assassins.select_single({:person_id => POPE.user.person_id, 
                                               :conference_id=>@current_conference.conference_id} ).target_id
    DebConf::Dc_assassins_kills.select_or_new({:person_id => foo,
                                               :killed_by => POPE.user.person_id,
                                               :conference_id=>@current_conference.conference_id} ).write
    redirect_to( :action => :index )

  end

  def admin_start
    initialize_set
    redirect_to( :action => :admin )
  end

  def admin
    @content_title = "Assassins"
    @content_subtitle = "S3kr3t cabal page"
    @started = false
    begin 
      game = DebConf::Dc_conference.select_or_new({:conference_id=>@current_conference.conference_id})
      @started = game.assassins_started
    rescue
    end

    @hunting = DebConf::View_dc_assassin_pairs.select({:conference_id=>@current_conference.conference_id},
                                                      {:ignore_empty => true} )
    @pending = DebConf::View_dc_assassination_victims.select({:acked_kill => false,
                                                              :conference_id=>@current_conference.conference_id},
                                                             {:ignore_empty => true} )
    @dead = DebConf::View_dc_assassination_victims.select({:conference_id=>@current_conference.conference_id,
                                                           :acked_kill => true},
                                                          {:ignore_empty => true} )
  end

  def admin_list
    @killers = DebConf::View_dc_conference_person.select({:conference_id => @current_conference.conference_id,
                                                           :assassins => true
                                                         })
    @kills = DebConf::Dc_assassins_kills.select({:conference_id => @current_conference.conference_id})
  end

  def admin_kill
  end

  def winners
    @content_title = "Assassins"
    @content_subtitle = "No winner yet"
    begin
      assassins = DebConf::Dc_conference.select_single({:conference_id => @current_conference.conference_id})
    rescue
      return redirect_to( :action => :have_patience)
    end

    @display = false
    if assassins.assassins_ended == true and assassins.display_winner == true
      @content_subtitle = "Ladies and gentlemen, we have a winner!"
      @display = true
      players = DebConf::View_dc_assassins.select({:conference_id=>@current_conference.conference_id},
                                                  {:ignore_empty => true} )
      @dead = DebConf::View_dc_assassination_victims.select({:conference_id=>@current_conference.conference_id},
                                                            {:ignore_empty => true} )

      @killers = DebConf::View_dc_assassination_killers.select({:conference_id=>@current_conference.conference_id},
                                                               {:ignore_empty => true} )

      @total = {}
      @killers.each do |killer|
        @total[killer.kills] ||= [] 
        @total[killer.kills] << killer.name
      end
    end

  end

  def already_done
    @content_title = "Assassins"
    @content_subtitle = "Stop it"
  end

  def have_patience
    @content_title = "Assassins"
    @content_subtitle = "All your assassins are belong to us"
  end

  def confirm_kill
    @content_title = "Assassins"
    @content_subtitle = "The rumors of your death are not so exaggerated"
    begin
      @is_killed = DebConf::Dc_assassins_kills.select_single({:person_id => POPE.user.person_id,
                                                             :conference_id=>@current_conference.conference_id})
    rescue Momomoto::Nothing_found
      return redirect_to( :action => :index )
    end

    if @is_killed.acked_kill == true
      return redirect_to( :action => :already_killed )
    end
    @killer = DebConf::View_dc_assassins.select_single({:conference_id=>@current_conference.conference_id, 
                                                        :person_id => @is_killed.killed_by})
  end

  def save_confirm_kill
    person = ''
    if POPE.permission?('pentabarf_login') and params[:person_id]
      person = params[:person_id]
    else
      person = POPE.user.person_id
    end

    @is_killed = DebConf::Dc_assassins_kills.select_single({:person_id => person,
                                                            :conference_id=>@current_conference.conference_id})
    @is_killed.acked_kill = true
    @is_killed.write

    expand_set
  end

  def already_killed
    @content_title = "Assassins"
    @content_subtitle = "You are dead"
  end

  protected

  def init
    @current_conference = Conference.select_single(:conference_id => POPE.user.current_conference_id) rescue Conference.new(:conference_id=>0)
    @preferences = POPE.user.preferences
    @current_language = POPE.user.current_language || 'en'
  end

  def check_permission
    case params[:action]
    when 'admin', 'admin_start', 'admin_list', 'admin_kill'
      return true if POPE.permission?('pentabarf_login')
    else
      return true if POPE.permission?('submission_login')
    end
    false
  end

  def clean
    DebConf::Dc_assassins.select({:conference_id=>@current_conference.conference_id} ).each do |row|
      row.delete
    end
  end

  def initialize_set
    killers = []
    linked_list = {}
    dc_conf = DebConf::Dc_conference.select_or_new({:conference_id=>@current_conference.conference_id})
    if dc_conf.assassins_started
      return redirect_to( :action => :already_done )
      
    end

    expand_set

    write_row (DebConf::Dc_conference, {:conference_id=>@current_conference.conference_id, 
                                        :assassins_started => true})
  end

  def expand_set
    current = []
    new = []
    killed = []
    DebConf::Dc_assassins.select({:conference_id=>@current_conference.conference_id}).each do |row|
      current << row.person_id
    end

    DebConf::View_dc_assassins.select({:conference_id => @current_conference.conference_id}).each do |ass|
      new << ass.person_id
    end

    DebConf::Dc_assassins_kills.select({:conference_id => @current_conference.conference_id}).each do |kill|
      killed << kill.person_id
    end

    new = new - killed
    new_users = new - current

    if new_users.length > 0
      new_users.shuffle!
      if current.length > 0
        insert_index = -1
        current.each_index do |i|
          begin
            DebConf::Dc_assassins_kills.select_single({:person_id => current[i],
                                                       :acked_kill => true,
                                                       :conference_id=>@current_conference.conference_id} )
            insert_index = i
            current[i] = nil
          rescue Momomoto::Nothing_found
          end
        end
        current.compact!
        current.insert(insert_index, new_users)
        current.flatten!
        clean
        current.each_index do |index|
          DebConf::Dc_assassins.select_or_new({:person_id => current[index],
                                               :target_id => current[-1] == current[index] ? current[0] : current[index+1],
                                               :conference_id=>@current_conference.conference_id} ).write
        end
      else
        new_users.each_index do |index|
          DebConf::Dc_assassins.select_or_new({:person_id => new_users[index],
                                               :target_id => new_users[-1] == new_users[index] ? new_users[0] : new_users[index+1],
                                               :conference_id=>@current_conference.conference_id} ).write
        end
      end
    else
      current.each_index do |i|
        begin
          DebConf::Dc_assassins_kills.select_single({:person_id => current[i],
                                                     :conference_id=>@current_conference.conference_id} )
          current[i] = nil
        rescue Momomoto::Nothing_found
        end
      end
      current.compact!
      clean
      current.each_index do |index|
        DebConf::Dc_assassins.select_or_new({:person_id => current[index],
                                             :target_id => current[-1] == current[index] ? current[0] : current[index+1],
                                             :conference_id=>@current_conference.conference_id} ).write
      end
    end
  end
end

