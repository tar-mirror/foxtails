require 'observable'

module Fox

  class FXObject
    extend Observable
    include Observable::Match
  end

  # All the basic properties of widgets should have reader/writer pairs that
  # take boolean or other values. This will let them be easily used as
  # targets of check buttons/menus etc. FXRuby already does this in most cases.

  class FXTextField
    alias :editable :editable? unless instance_methods(1).include?("editable")
    observable :editable    # make the reader and writer methods observable
  end
  
  class FXWindow
    alias :enabled :enabled? unless instance_methods(1).include?("enabled")
    unless instance_methods(1).include?("enabled=")
      def enabled=(x); x ? enable : disable; end
    end
    observable :enabled

    unless instance_methods(1).include?("shown=")
      def shown=(x); x ? show : hide; end
    end
    observable :shown
    
    ## drop_enabled
    
    observable :height, :width ## doesn't really work yet -- see simple.rb
    
    # Traverse all children, depth first (parent before child).
    def each_child_recursive
      each_child do |child|
        yield child
        child.each_child_recursive do |subchild|
          yield subchild
        end
      end
    end
  end

end

# Some FXRuby methods may still return truth values as 0 or 1.
# The #to_bool method converts safely to false or true. This
# should eventually be completely fixed in FXRuby.

class Integer
  def to_bool
    self != 0
  end
end

class TrueClass
  def to_bool; self; end
end

class FalseClass
  def to_bool; self; end
end

module FoxTails

  # Functions for storing simple objects as human-readable strings.

  # extracts consecutive decimal digits and returns the corresponding
  # integers in an array--safer than eval!
  def FoxTails.string_to_int_array(str)
    str.scan(/-?\d+/).map{|s|s.to_i}
  end

  # parses as "...", "...", ... and returns the corresponding
  # strings in an array--safer than eval!
  def FoxTails.string_to_string_array(str)
###
  end

end

