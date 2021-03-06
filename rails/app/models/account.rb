require 'yaml'
class Account < Momomoto::Table
  schema_name "auth"
  module Methods

    def password=( value )
      srand()
      salt = []
      8.times do salt << rand(256) end

      salt_bin, salt_hex = '', ''
      for number in salt
        salt_bin += sprintf('%c', number)
        salt_hex += sprintf('%02x', number)
      end

      hash = Digest::MD5.hexdigest( salt_bin + value.to_s )
      set_column( :salt, salt_hex )
      set_column( :password, hash )
    end

    def current_conference_id
      get_column(:current_conference_id) || 1
    end

    def current_language
      get_column(:current_language) || 'en'
    end

    def preferences
      YAML.load( get_column( :preferences ) ) rescue {}
    end

    def preferences=( value )
      set_column( :preferences, value.to_yaml )
    end

  end
end

