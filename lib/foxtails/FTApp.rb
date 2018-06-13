module FoxTails
  class FTApp < Fox::FXApp
  
    attr_accessor :icon_path

    def initialize(*args)
      super
      @icon_path = [File.join(File.dirname(__FILE__), 'icons')]
        ## what else? .foxrc/... ?
    end
    
    def run
      addSignal("SIGINT") { exit(1) }

      read_registry
      create  # Fox filters out some of ARGV, e.g. -display (right?)
      read_command_line

      super
### prevents subclasses from handling
###    rescue => e
###      error("Please report this bug:\n\n" + e.message)
    end
    
    def create
      @ft_app_created = true
      super
    end

    def error(msg = "An error occurred.", dialog = false)
      if dialog or RUBY_PLATFORM =~ /win32/i
        window = getRoot()
        create unless @ft_app_created
        FXMessageBox.error(window, MBOX_OK, "Error", msg)
        exit(1)
      else
        Kernel.raise
      end
    end
    
    # Searches for +name+ first in the list of +dirs+, then in +icon_path+.
    def get_icon name, *dirs
      for dir in dirs + @icon_path
        path = File.join(dir, name)
        begin
          data = File.open(path, "rb") {|f| f.read}
          case path
          when /png$/i
            icon = Fox::FXPNGIcon.new(self, data)
          when /gif$/i
            icon = Fox::FXGIFIcon.new(self, data)
          end
        rescue Errno::ENOENT
        else return icon
        end
      end
      nil
    end

    def exit code = 0
      write_registry if code == 0
      super code
    end

    def read_command_line
    end
    
    def write_registry
      reg.asciiMode = false
    end

    def read_registry
      reg.asciiMode = false
    end
    
    def beginWaitCursor
      @ft_app_created ? super : yield ## this is really a bug in FXApp...
    end

  end

end
