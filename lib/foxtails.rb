module FoxTails
  FXVER = "16"
end

FOXLIBNAME = "fox#{FoxTails::FXVER}"
require FOXLIBNAME

require 'observable'

# general-purpose extensions and utilities
require 'foxtails/utils'

# Standard icons culled from Fox lib and examples: file, edit, browse, view...
require 'foxtails/icons'              

# Some simple, commonly used dialogs: messages, warnings, exceptions.
require 'foxtails/dialogs'

# Extensions to Fox classes.
require 'foxtails/FXSettings'         # overflow checking, array entries
require 'foxtails/FXTable'            # deselectRange

# Observable tree mixin, usable with FTTreeList.
autoload :Treelike, 'treelike'
autoload :ArrayTree, 'treelike/array-tree'
autoload :SortedTree, 'treelike/sorted-tree'

module FoxTails
  {
    # New subclasses of Fox classes and other new classes and modules.

    # Handles common app tasks: icons, errors, signals, registry, command line.
    [ :FTApp                ]   => 'foxtails/FTApp',

    # Issues warning via a chore.
    [ :FTWarning            ]   => 'foxtails/FTWarning',

    # Dynamically constructed popup button using a closure.
    [ :FTPopupButton        ]   => 'foxtails/FTPopupButton',

    # Controls using FTTargeted and Observable, an alternative to FXDataTarget.
    
    [ :FTCheckMenuCommand,
      :FTRadioMenuCommand,
      :FTEnabledMenuCommand ]   => 'foxtails/FTMenuCommand',
    
    [ :FTComboBox           ]   => 'foxtails/FTComboBox',
    
    [ :FTOptionMenu         ]   => 'foxtails/FTOptionMenu',
    
    [ :FTTextField,
      :FTStringField,
      :FTIntegerField,
      :FTFloatField,        ]   => 'foxtails/FTTextField',
    
    [ :FTField              ]   => 'foxtails/FTField',
    
    [ :FTButton,
      :FTCheckButton,
      :FTToggleButton,
      :FTRadioButton,
      :FTEnabledButton,
      :FTActionButton       ]   => 'foxtails/FTButton',
    
    [ :FTSlider,
      :FTSpinner,
      :FTDial,
      :FTScrollBar,
      :FTScrollbar,
      :FTProgressBar        ]   => 'foxtails/FTLinearControl',

    [ :FTList               ]   => 'foxtails/FTList',
    
    [ :FTTreeItem,
      :FTTreeList           ]   => 'foxtails/FTTreeList',
    
    # Complex widgets.
    
    [ :FTFileBrowser        ]   => 'foxtails/FTFileBrowser',
    
    # Mixin
    
    [ :FTNonModal           ]   => 'foxtails/FTNonModal'
    
  }.each {|mods, file| mods.each {|mod| autoload mod, file} }
  
end
