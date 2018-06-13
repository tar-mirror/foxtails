require 'foxtails/FTTargeted'

## tip text

module FoxTails
  class FTFileBrowser < Fox::FXFileList
    include FTStateTargeted
    extend Observable
    
    attr_accessor :bookmarks ## should be observable...
    
    observable :show_hidden_state, :show_icons_state, :arrange_state,
               :shown_state
               ### bad names, better: hidden_files_shown, arrange_by

    observable :directory, # this makes FXFileList#directory observable
               :can_go_up, :can_write
    
    signal :files_chosen
  
    def target_arg_range; 1..2; end

    def initialize parent, target, state,
                    opts = LAYOUT_FILL_X|FRAME_RAISED,
                    filelist_opts = ICONLIST_MINI_ICONS|ICONLIST_AUTOSIZE
      
      FoxTails.get_file_icons
      FoxTails.get_browse_icons
      
      @outer_frame = FXHorizontalFrame.new(parent, opts)

      inner_frame = FXHorizontalFrame.new(@outer_frame,
        FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X|LAYOUT_FILL_Y,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
      
      super(inner_frame, target, state,
            LAYOUT_FILL_X|LAYOUT_FILL_Y|filelist_opts)
      
      connect(SEL_DOUBLECLICKED, method(:onCmdFileList))
      connect(SEL_RIGHTBUTTONRELEASE, method(:onPopupMenu))
      
      btn_frame = FXVerticalFrame.new(@outer_frame)
      
      ## need a drive box button for windows
      
      FTEnabledButton.new(btn_frame,
        "\tUp one level\tGo up to higher directory.",
        UPLEVEL_ICON, self, :can_go_up, BUTTON_TOOLBAR|FRAME_RAISED).
        connect(SEL_COMMAND) {on_cmd_up_dir}

      FXButton.new(btn_frame, "\tGo home\tGo to home directory.",
        HOME_ICON, self, 0, BUTTON_TOOLBAR|FRAME_RAISED).
        connect(SEL_COMMAND) {on_cmd_home_dir}

      FTEnabledButton.new(btn_frame,
        "\tCreate new directory\tCreate new directory.",
        NEW_DIR_ICON, self, :can_write, BUTTON_TOOLBAR|FRAME_RAISED).
        connect(SEL_COMMAND) {on_cmd_new_dir}

      FTPopupButton.new(btn_frame, "\tBookmarks\tBookmarks.",
        MARK_ICON, self, 0, BUTTON_TOOLBAR|FRAME_RAISED) {make_bookmark_popup}
      
      self.shown_state      = true
      self.show_icons_state = :mini
      self.arrange_state    = :by_rows
      
      when_shown_state(true)  { @outer_frame.shown=true; recalc } ## how to recalc?
      when_shown_state(false) { @outer_frame.shown=false; recalc }
      
      when_show_icons_state(:big)      { show_big_icons     }
      when_show_icons_state(:mini)     { show_mini_icons    }
      when_show_icons_state(:details)  { show_details      }

      when_arrange_state(:by_rows)     { arrange_by_rows    }
      when_arrange_state(:by_columns)  { arrange_by_columns }
      
      when_show_hidden_state BOOLEAN do |bool|
        self.hiddenFilesShown = bool
      end
    end
    
    def show_big_icons
      handle(self, MKUINT(FXIconList::ID_SHOW_BIG_ICONS, SEL_COMMAND), nil)    
    end
    
    def show_mini_icons
      handle(self, MKUINT(FXIconList::ID_SHOW_MINI_ICONS, SEL_COMMAND), nil)    
    end
    
    def show_details
      handle(self, MKUINT(FXIconList::ID_SHOW_DETAILS, SEL_COMMAND), nil)    
    end
    
    def arrange_by_rows
      handle(self, MKUINT(FXIconList::ID_ARRANGE_BY_ROWS, SEL_COMMAND), nil)    
    end
    
    def arrange_by_columns
      handle(self, MKUINT(FXIconList::ID_ARRANGE_BY_COLUMNS, SEL_COMMAND), nil)    
    end
    
    def connect_to_target
      # The order of the two when_ clauses is significant: this way, when self
      # and target are created, the target's directory propagetes to self,
      # instead of vice versa. (This is the only gotcha with circular
      # observables.)
      when_target_state CHANGES do |dir|
        self.directory = dir
      end

      when_directory CHANGES do |dir|
        ## this should probably be a method, so subclasses can extend
        self.can_go_up = (dir != File.dirname(dir))
        self.can_write = File.writable?(dir)
          # note that the above two are not updated as the file system changes
          # (unlike FXFileSelector)
        set_target_state(dir)
        setHelpText(dir)
      end
    end
    
    ## this isn't quite the right approach--it becomes impossible to
    ## access the FXFileList methods. Probable, FTFileBrowser should
    ## not inherit but delegate.
    def show;       @outer_frame.show;       end
    def hide;       @outer_frame.hide;       end
    def height;     @outer_frame.height;     end
    def height=(h); @outer_frame.height = h; end
#    def enable;     @outer_frame.enable;     end
#    def disable;    @outer_frame.disable;    end
    
    # Command message from the file list
    def onCmdFileList(sender, sel, index)
      if index >= 0
        open_selection(index)
      end
      return 1
    end

    def open_selection index
      if isItemDirectory(index)
        self.directory = getItemPathname(index)
      elsif isItemFile(index)
        items = (0...getNumItems).select do |i|
          if isItemDirectory(i)
            deselectItem(i)
            false
          else
            isItemSelected(i)
          end
        end
        names = items.map {|index| getItemPathname(index)}
        self.files_chosen = names
        open_named_files(names)
      end
    end
    
    # can override this method as alternative to using files_chosen signal
    def open_named_files(names)
    end
    
    def onPopupMenu sender, sel, event
      # based on FXFileSelector::onPopupMenu

      if event.moved then return 1 end

      index = getItemAt(event.win_x, event.win_y)
      
      # Suggested by Thien Vuong
      if !isItemSelected(index)
        killSelection
        setCurrentItem(index)
        selectItem(index)
      end

      filemenu = FXMenuPane.new(self)
      
      FTEnabledMenuCommand.new(filemenu, "Up one level", UPLEVEL_ICON,
        self, :can_go_up).
        connect(SEL_COMMAND) {on_cmd_up_dir}

      FXMenuCommand.new(filemenu, "Go home", HOME_ICON).
        connect(SEL_COMMAND) {on_cmd_home_dir}
      
      FTEnabledMenuCommand.new(filemenu, "New directory...", NEW_DIR_ICON,
        self, :can_write).
        connect(SEL_COMMAND) {on_cmd_new_dir}

      FXMenuSeparator.new(filemenu)

      sortmenu = FXMenuPane.new(self)
      FXMenuCascade.new(filemenu, "Sort by", nil, sortmenu)
      FXMenuCommand.new(sortmenu, "Name",    nil, self, ID_SORT_BY_NAME)
      FXMenuCommand.new(sortmenu, "Type",    nil, self, ID_SORT_BY_TYPE)
      FXMenuCommand.new(sortmenu, "Size",    nil, self, ID_SORT_BY_SIZE)
      FXMenuCommand.new(sortmenu, "Time",    nil, self, ID_SORT_BY_TIME)
      FXMenuCommand.new(sortmenu, "User",    nil, self, ID_SORT_BY_USER)
      FXMenuCommand.new(sortmenu, "Group",   nil, self, ID_SORT_BY_GROUP)
      FXMenuCommand.new(sortmenu, "Reverse", nil, self, ID_SORT_REVERSE)

      viewmenu = FXMenuPane.new(self)
      FXMenuCascade.new(filemenu, "View", nil, viewmenu)

      FTRadioMenuCommand.new(viewmenu, "Small icons", nil, self,
        :show_icons_state, :mini)
      FTRadioMenuCommand.new(viewmenu, "Big icons", nil, self,
        :show_icons_state, :big)
      FTRadioMenuCommand.new(viewmenu, "Details", nil, self,
        :show_icons_state, :details)

      FXMenuSeparator.new(viewmenu)

      FTRadioMenuCommand.new(viewmenu, "Rows", nil, self,
        :arrange_state, :by_rows)
      FTRadioMenuCommand.new(viewmenu, "Columns", nil, self,
        :arrange_state, :by_columns)

      FXMenuSeparator.new(viewmenu)

      FTCheckMenuCommand.new(viewmenu, "Hidden files", nil, self,
        :show_hidden_state)

      bm_menu = FXMenuPane.new(self)
      FXMenuCascade.new(filemenu, "Bookmarks", nil, bm_menu)
      FXMenuCommand.new(bm_menu, "Set bookmark", MARK_ICON).
        connect(SEL_COMMAND) {set_bookmark}

      if @bookmarks
        FXMenuCommand.new(bm_menu, "Clear bookmarks", CLEAR_MARKS_ICON).
          connect(SEL_COMMAND) {clear_bookmarks}

        FXMenuSeparator.new(bm_menu)
        
        @bookmarks.each do |bm|
          FXMenuCommand.new(bm_menu, bm).connect(SEL_COMMAND) {open_bookmark bm}
        end
      end

      FXMenuSeparator.new(filemenu)

      open_cmd = FXMenuCommand.new(filemenu, "Open...", FILE_OPEN_ICON)
      if index >= 0
        open_cmd.connect(SEL_COMMAND) {open_selection(index)}
      else
        open_cmd.disable
      end
      
## RENAME?
##      FXMenuCommand.new(filemenu, "Copy...", COPY_ICON, self,0)###
##      FXMenuCommand.new(filemenu, "Move...", MOVE_ICON, self,0)###
##      FXMenuCommand.new(filemenu, "Link...", LINK_ICON, self,0)###

      del_cmd = FXMenuCommand.new(filemenu, "Delete...", DELETE_ICON)
      if index >= 0 and isItemSelected(index) ## now, always selected
        del_cmd.connect(SEL_COMMAND) {on_cmd_delete_files}
      else
        del_cmd.disable
      end

      filemenu.create()
      filemenu.popup(nil, event.root_x, event.root_y)
      filemenu.grabKeyboard
      getApp().runModalWhileShown(filemenu)
      return 1
    end

    def set_bookmark
      unless @bookmarks and @bookmarks.include? directory
        (@bookmarks ||= []) << directory
        @bookmarks.shift while @bookmarks.size > 10
      end
    end

    def clear_bookmarks
      @bookmarks = nil
    end

    def open_bookmark bm
      self.directory = bm
    end
    
    def make_bookmark_popup
      bm_menu = FXMenuPane.new(self,POPUP_SHRINKWRAP)

      ## copied from above
      FXMenuCommand.new(bm_menu, "Set bookmark", MARK_ICON).
        connect(SEL_COMMAND) {set_bookmark}

      if @bookmarks
        FXMenuCommand.new(bm_menu, "Clear bookmarks", CLEAR_MARKS_ICON).
          connect(SEL_COMMAND) {clear_bookmarks}

        FXMenuSeparator.new(bm_menu)
        
        @bookmarks.each do |bm|
          FXMenuCommand.new(bm_menu, bm).connect(SEL_COMMAND) {open_bookmark bm}
        end
      end
      
      bm_menu
    end
    
    def on_cmd_up_dir
      d = directory.sub(/\/$/, "")
      self.directory = File.dirname(d)
    end
    
    def on_cmd_home_dir
      self.directory = ENV['HOME'] ||
                       ENV['USERPROFILE'] ||
                       ENV['HOMESHARE']
    end

    def on_cmd_new_dir
      # adapted from FXFileSelector::onCmdNew
      dir = directory
      name = FXInputDialog.getString(
              "DirectoryName", self, "Create New Directory",
              "Create new directory in: #{dir}", NEW_DIR_ICON)
      if name
        dirname = File.join(dir, name)
        begin
          Dir.mkdir(dirname)
        rescue Errno::EACCES
          FXMessageBox.error(self, MBOX_OK, "Cannot Create",
            "Cannot create directory #{dirname}.\n")
        rescue Errno::EEXIST
          FXMessageBox.error(self, MBOX_OK, "Already Exists",
            "Directory #{dirname} already exists.\n")
        end
      end
    end
    
    def on_cmd_delete_files
      # adapted from FXFileSelector::onCmdDelete
      dir = directory
      for item in 0...getNumItems
        if isItemSelected(item)
          name = getItemFilename(item)
          next if name == '..'
          fullname = File.join(dir, name)
          answer = FXMessageBox.warning(self, MBOX_YES_NO_CANCEL,
            "Deleting files",
            "Are you sure you want to delete the file:\n\n#{fullname}")
          case answer
          when MBOX_CLICKED_CANCEL; break
          when MBOX_CLICKED_NO;     next
          end
          begin
            if File.directory?(fullname)
              Dir.rmdir fullname # unlike onCmdDelete, do NOT rm-rf
            else
              File.delete fullname
            end
          rescue => e
            break if MBOX_CLICKED_NO==FXMessageBox.error(self, MBOX_YES_NO,
              "Error Deleting File",
              "Unable to delete file:\n\n#{fullname}\n\n#{e.message}\n\n" +
              "Continue with operation?")
          end
        end
      end
    end

  end
end
