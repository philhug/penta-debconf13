module DebConf

  def self.const_missing( table )
    klass = Class.new( Momomoto::Table )
    klass.schema_name = "debconf"
    DebConf.const_set(table, klass)
  end

end
