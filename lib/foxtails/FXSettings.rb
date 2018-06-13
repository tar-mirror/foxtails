require 'foxtails/utils'

module Fox
  # <b>Note:<\b> I no longer recommend using Fox's settings mechanism--
  # it is too limited in terms of data size and structure. A better alternative,
  # if YAML is acceptable, is http://raa.ruby-lang.org/project/preferences/.

  class FXSettings

    class StringOverflow < StandardError; end
    
    # These limits are from FXSettings.cpp. Must manually update. Argh!
    MAXBUFFER = 2000-1  # line length
    MAXNAME   = 200-1   # key length
    MAXVALUE  = 2000-1  # value length
    
    # Methods for persisting *small* Ruby objects in the FOX registry (or
    # other settings files) in human-readable form.
    
    # Check the entry against the limits.
    def check_entry(section, key, value)
      if section.length > MAXNAME
        raise StringOverflow,
              "FXSettings section '#{section[0..50]}...'\n" +
              "  is #{section.length} bytes; limit is #{MAXNAME}."
      end

      if key.length > MAXNAME
        raise StringOverflow,
              "FXSettings key '#{key[0..50]}...'\n" +
              "  in section [#{section}]\n" +
              "  is #{key.length} bytes; limit is #{MAXNAME}."
      end

      if value.length > MAXVALUE
        raise StringOverflow,
              "FXSettings value '#{value[0..50]}...'\n" +
              "  associated with key '#{key}' in section [#{section}]\n" +
              "  is #{value.length} bytes; limit is #{MAXVALUE}."
      end

      if key.length + value.length + 1 > MAXBUFFER
        raise StringOverflow,
              "FXSettings key '#{key[0..50]}...'\n" +
              "  and value '#{value[0..50]}...'\n" +
              "  in section [#{section}]\n" +
              "  are #{key.length + value.length + 1} bytes;" +
               " limit is #{MAXBUFFER}."
      end
    end
    
    # Adds error checking to existing writeStringEntry method.
    alias :old_writeStringEntry :writeStringEntry
    def writeStringEntry(section, key, value)
      check_entry(section, key, value)
      old_writeStringEntry(section, key, value)
    end
    
    # Reads an array of decimal integers separated by any non-digit chars.
    def readIntArrayEntry(section, key, default = [])
      if existingEntry(section, key)
        str = readStringEntry(section, key, "")
        FoxTails.string_to_int_array(str)
      else
        default
      end
    end
    
    # Writes an array of decimal integers, separated by ", ".
    def writeIntArrayEntry(section, key, value)
      v = value.map {|x| x.to_i} # returns array of int, or raises an exception
      writeStringEntry(section, key, v.join(", "))
    end
  end
end
